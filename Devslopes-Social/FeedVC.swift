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

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
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
            print("MSH: \(post.caption)")
            postCell.configureCell(post: post)
            return postCell
            
        } else {
            return PostCell()
        }
    }
    
    @IBAction func signOutTapped(_ sender: UITapGestureRecognizer) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MSH: Id removed from keychain\(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        dismiss(animated: true, completion: nil)
    }
}
