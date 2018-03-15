//
//  ContactTableViewCell.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 20/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import Contacts

class ContactTableViewCell: UITableViewCell {
    
    func setCircularAvatar() {
        self.imageView?.layer.cornerRadius = self.imageView!.bounds.size.width / 2.0
        self.imageView?.layer.masksToBounds = true
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setCircularAvatar()
    }
    
    func configureWithContactEntry(_ contact: ContactEntry) {
        
        if contact.name.isEmpty {
            self.textLabel?.text = contact.surName!
        } else if contact.surName.isEmpty {
            self.textLabel?.text = contact.name!
        } else {
            self.textLabel?.text = contact.name + " " + contact.surName
        }
        
        self.detailTextLabel?.text = contact.phone ?? ""
        self.imageView?.image = contact.image ?? UIImage(named: "defaultUser")
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        setCircularAvatar()
    }
    
    
}
