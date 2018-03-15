//
//  SignInToContinueViewController.swift
//  Locnote
//
//  Created by Ruzhin Alexey on 20.10.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit
//import FacebookCore
//import FacebookLogin
//import FacebookShare
//import TwitterKit


class SignInToContinueViewController: UIViewController {
    
    // MARK: Properties
    var social: String!
    
    
    // MARK: - Button's Constraints Outlets
    @IBOutlet weak var constraint1: NSLayoutConstraint!
    @IBOutlet weak var constraint2: NSLayoutConstraint!
    @IBOutlet weak var constraint3: NSLayoutConstraint!
    @IBOutlet weak var constraint4: NSLayoutConstraint!
    @IBOutlet weak var constraint5: NSLayoutConstraint!
    
    
    // MARK: - View Methods Override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setConstrainntsForButtons()
    }
    
    // MARK: - Social Buttons
    @IBAction func facebookLogin(_ sender: UIButton) {
        social = "Facebook"
        performSegue(withIdentifier: "toAuthorizationControllerSegue", sender: self)
    }
    
    @IBAction func googleLogin(_ sender: UIButton) {
        social = "Google"
        performSegue(withIdentifier: "toAuthorizationControllerSegue", sender: self)
    }
    
    @IBAction func instagramLogin(_ sender: UIButton) {
        social = "Instagram"
        performSegue(withIdentifier: "toAuthorizationControllerSegue", sender: self)
    }
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        social = "Twitter"
        performSegue(withIdentifier: "toAuthorizationControllerSegue", sender: self)
    }
    
    // MARK: - View Setup
    func setConstrainntsForButtons() {
        let displayWidth = UIScreen.main.bounds.width
        let constraintsWidth = displayWidth / 6.5 / 2
        self.constraint1.constant = constraintsWidth
        self.constraint2.constant = constraintsWidth
        self.constraint3.constant = constraintsWidth
        self.constraint4.constant = constraintsWidth
        self.constraint5.constant = constraintsWidth
    }
    
    // MARK: - Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAuthorizationControllerSegue" {
            let nextVC = segue.destination as! AuthorizationViewController
            nextVC.social = self.social
            
        }
    }
    
}
