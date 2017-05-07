//
//  PostCell.swift
//  Devslopes-Social
//
//  Created by Mohammad Hemani on 5/5/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    func configureCell(post: Post) {
        
        caption.text = post.caption
        likesLabel.text = String(post.likes)
        
    }
    
    

}
