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

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func emailPasswordLoginTapped(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error as NSError? {
                    
                    if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
                        
                        switch (errorCode) {
                        case .errorCodeUserNotFound:
                            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                                if let error = error as NSError? {
                                    
                                    if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
                                        
                                        switch (errorCode) {
                                        case .errorCodeWeakPassword:
                                            self.showErrorAlert(title: "Weak Password", message: "Please enter a stronger password")
                                        default:
                                            print(error.debugDescription)
                                        }
                                    }
                                } else {
                                    print("MSH: Successfully authenticated with Firebase with new email/password")
                                }
                            })
                        case .errorCodeInvalidEmail:
                            self.showErrorAlert(title: "Invalid Email Format", message: "Please enter a proper email address")
                        case .errorCodeWeakPassword:
                            self.showErrorAlert(title: "Weak Password", message: "Please enter a stronger password")
                        case .errorCodeWrongPassword:
                            self.showErrorAlert(title: "Wrong Password", message: "Please enter the correct password")
                        default:
                            print(error.debugDescription)
                        }
                    }
                } else {
                    print("MSH: Email user authenticated with Firebase")
                }
            })
        }
    }

    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("MSH: Unable to authenticate with Firebase: \(error.debugDescription)")
            } else {
                print("MSH: Facebook user authenticated with Firebase")
            }
        })
    }
    
    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

}

