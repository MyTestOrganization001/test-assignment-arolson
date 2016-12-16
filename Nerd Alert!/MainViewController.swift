//
//  MainViewController.swift
//  Nerd Alert!
//
//  Created by Andrew Olson on 11/15/16.
//  Copyright © 2016 Valhalla Applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FBSDKLoginKit
import FirebaseFacebookAuthUI

class MainViewController: UIViewController {
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var swipeButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    

    fileprivate var authHandle: FIRAuthStateDidChangeListenerHandle!
    var user: FIRUser?
    var displayName = "Unknown User"

    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureAuth()
        layoutButtons()
    }
   
    @IBAction func signOutAction(_ sender: UIBarButtonItem)
    {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    func layoutButtons()
    {
        messageButton.imageView?.contentMode = .scaleAspectFit
        searchButton.imageView?.contentMode = .scaleAspectFit
        swipeButton.imageView?.contentMode = .scaleAspectFit
        profileButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.imageView?.contentMode = .scaleAspectFit
    }
    //setup view's depending on the signed in status
    func signed(in: Bool)
    {
    
    }
    //MARK: Deinit
    deinit {
        FIRAuth.auth()?.removeStateDidChangeListener(authHandle)
        print("Deinit")
    }
}
//MARK: Facebook Button Delegete
extension MainViewController: FBSDKLoginButtonDelegate
{
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if error != nil
        {
            print("Facebook login error \(error)")
            return
        }
        if result.isCancelled
        {
        
            print("Facebook login canceled.")
            return
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        configureAuth(credential: credential)
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        //Handle Facebook logout here
    }
}
//MARK: Firebase Login - Configuration
extension MainViewController
{
    //configuring Google and Email Authentication
    func configureAuth()
    {
        FIRAuthUI.default()?.providers = [FIRGoogleAuthUI(),FIRFacebookAuthUI()]
        authHandle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            //check if the user is active.
            if let activeUser = user {
                if self.user != activeUser
                {
                    self.user = activeUser
                    if let name = activeUser.displayName?.components(separatedBy: " ")[0]
                    {
                        self.displayName = name
                    }
                    else
                    {
                        let name = activeUser.email?.components(separatedBy: "@")[0]
                        self.displayName = name!
                    }
                    print("User: \(self.displayName)")
                    self.signed(in: true)
                }
            }
            else
            {
                self.signed(in: false)
                self.loginSession()
            }
            
        })
    }
    // Configuring Facebook Authentication with Firebase database
    func configureAuth(credential: FIRAuthCredential)
    {
        print("\nUser Credential : \(credential)\n")
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            
            if let error = error
            {
                print("Error - Facebook Login:  \(error.localizedDescription)")
                return
            }
            if let activeUser = user
            {
                if self.user != activeUser
                {
                    self.user = activeUser
                    self.signed(in: true)
                    let name = user?.email?.components(separatedBy: "@")[0]
                    self.displayName = name!
                    print("User: \(name)")
                }
            }
            else
            {
                self.signed(in: false)
                self.loginSession()
            }
        }
    }
    //Create the Authenticating View Controller
    func loginSession()
    {
        let authViewController = FIRAuthUI.default()?.authViewController()
        present(authViewController!, animated: true, completion: nil)
    }
}
