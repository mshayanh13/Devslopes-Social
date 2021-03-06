//
//  FeedVC.swift
//  Devslopes-Social
//
//  Created by Mohammad Hemani on 5/4/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let defaultImage = UIImage(named: "add-image")
    var imagePicker: UIImagePickerController!
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts.removeAll()
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
            
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let postCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            
            let post = posts[indexPath.row]
            
            if let image = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                postCell.configureCell(post: post, image: image)
            } else {
                postCell.configureCell(post: post)
            }
            return postCell
            
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
        } else {
            print("MSH: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addImageTapped(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let caption = captionTextField.text, caption != "" else {
            showErrorAlert(title: "Caption Empty", message: "Must enter caption!")
            return
        }
        guard let image = imageAdd.image, image != defaultImage else {
            showErrorAlert(title: "No Image", message: "An image must be selected")
            return
        }
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            
            let imageUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.ds.REF_POST_IMAGES.child(imageUid).put(imageData, metadata: metadata, completion: { (metadata, error) in
                if let _ = error {
                    print("MSH: Unable to upload image to Firebase storage")
                }
                if let metadata = metadata {
                    print("MSH: Successfully uploaded image to Firebase storage")
                    let metadataURL = metadata.downloadURL()?.absoluteString
                }
            })
        }
        
        resetPostView()
    }
    
    @IBAction func signOutTapped(_ sender: UITapGestureRecognizer) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MSH: Id removed from keychain\(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        dismiss(animated: true, completion: nil)
    }
    
    func resetPostView() {
        captionTextField.text = ""
        imageAdd.image = defaultImage
    }
    
    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}
