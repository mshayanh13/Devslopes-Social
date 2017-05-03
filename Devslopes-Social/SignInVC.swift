//
//  SignInVC.swift
//  Devslopes-Social
//
//  Created by Mohammad Hemani on 4/30/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func facebookLoginTapped(_ sender: UIButton) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MSH: Unable to authenticate to Facebook: \(error.debugDescription)")
            } else if result?.isCancelled == true {
                print("MSH: User cancelled facebook authentication")
            } else {
                print("MSH: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }

    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("MSH: Unable to authenticate with Firebase: \(error.debugDescription)")
            } else {
                print("MSH: Successfully authenticated with Firebase")
            }
        })
    }

}

