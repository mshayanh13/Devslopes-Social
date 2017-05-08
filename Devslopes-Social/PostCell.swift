//
//  PostCell.swift
//  Devslopes-Social
//
//  Created by Mohammad Hemani on 5/5/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    func configureCell(post: Post, image: UIImage? = nil) {
        
        caption.text = post.caption
        likesLabel.text = String(post.likes)
        
        if let image = image {
            self.postImage.image = image
        } else {
            
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if let _ = error {
                    print("MSH: Unable to download image from Firebase Storage")
                }
                if let imageData = data {
                    print("MSH: Image downloaded from Firebase Storage")
                    if let image = UIImage(data: imageData) {
                        self.postImage.image = image
                        FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                    }
                }
            })
            
        }
    }
    
    

}
