//
//  SettingsTableViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 29.11.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBAction func doneButtoneClicked(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
   
    @IBAction func signOutButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Attantion!",
                                      message: "Are you shure?",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "YES",
                                      style: UIAlertActionStyle.default,
                                      handler: { (UIAlertAction) in
                                        self.navigationController!.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "NO",
                                      style: UIAlertActionStyle.cancel,
                                      handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}


