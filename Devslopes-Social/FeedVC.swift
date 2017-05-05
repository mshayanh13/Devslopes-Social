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

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        //let keychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MSH: Id removed from keychain\(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        dismiss(animated: true, completion: nil)
    }
}
