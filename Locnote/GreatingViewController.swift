//
//  GreatingViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 02.01.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit
import FacebookCore


class GreatingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(self.toSignInViewController), with: nil, afterDelay: 1)
    }
    
    func toSignInViewController() {
        performSegue(withIdentifier: "toSignInSegue", sender: self)
    }

}
