//
//  AuthorizationViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 16.01.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit

import FacebookCore
import FacebookLogin
import FacebookShare
import TwitterKit
import InstagramSDK_iOS


class AuthorizationViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // MARK: Properties
    var social = ""
    
    // MARK: - View Methods Override
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch social {
        case "Facebook":
            perform(#selector(self.facebookLogin), with: nil, afterDelay: 1)
        case "Google":
            perform(#selector(self.googleLogin), with: nil, afterDelay: 1)
        case "Instagram":
            perform(#selector(self.instagramLogin), with: nil, afterDelay: 1)
        case "Twitter":
            perform(#selector(self.twitterLogin), with: nil, afterDelay: 1)
        default:
            print("No Social is Selected!")
        }
    }
    
    // MARK: - Social Methods
    func facebookLogin() {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .cancelled: print("Authorization cancelled")
            case .failed(let error): print("Authorization error: \(error)")
            case .success( _, _, _):
                self.authorizeUserWith(social: self.social)
            }
        }
    }
    
    func googleLogin() {
        let btnn = GIDSignInButton.init()
        btnn.sendActions(for: .touchUpInside)
    }
    
    func instagramLogin() {
//        InstagramAppCenter.default().login { (result, error) in
//            self.loadUserProfileFromInstagram()
//            self.authorizeUserWith(social: self.social)
//        }
        self.authorizeUserWith(social: self.social)
    }
    
    func twitterLogin() {
        Twitter.sharedInstance().logIn { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)");
                self.authorizeUserWith(social: self.social)
            } else {
                print("error: \(error!.localizedDescription)");
            }
        }
    }
    
    
    // MARK: - Instagram Authorization
    func loadUserProfileFromInstagram() {
        InstagramAppCenter.default().apiCall(withPath: IGApiPathUsersSelf, param: nil) { (result, error) in
            print("result, error -> \(result), \(error)" )
        }
    }
    
    
    // MARK: - Google SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            self.authorizeUserWith(social: self.social)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    
    // MARK: -
    func authorizeUserWith(social: String) {
        UserDefaults.standard.set(social, forKey: "userAuthorizedBy")
        self.performSegue(withIdentifier: "toMainControllerSegue", sender: self)
    }
    



}
