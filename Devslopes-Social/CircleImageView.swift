//
//  CircleImageView.swift
//  Devslopes-Social
//
//  Created by Mohammad Hemani on 5/5/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
