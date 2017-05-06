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
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        clearTextFields()
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
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
                                    if let user = user {
                                        self.completeSignIn(user: user, provider: user.providerID)
                                    }
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
                    if let user = user {
                        self.completeSignIn(user: user, provider: user.providerID)
                    }
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
                if let user = user {
                    self.completeSignIn(user: user, provider: credential.provider)
                }
            }
        })
    }
    
    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func completeSignIn(user: FIRUser, provider: String) {
        let id = user.uid
        DataService.ds.createFirebaseDBUser(uid: id, userData: ["provider": provider])
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("MSH: Data saved to keychain: \(keychainResult)")
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = segue.destination as? FeedVC {
            
        }
    }
    
    func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}

