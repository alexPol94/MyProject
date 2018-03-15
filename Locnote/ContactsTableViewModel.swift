//
//  ContactsTableViewModel.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 20.01.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit

class ContactsTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    
    // MARK: - Properties
    var contacts = [ContactEntry]()
    var updateContactComplition: (() -> Void)?
    var isEditable: (() -> Bool)?
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEditable!() == true {
            if contacts.isEmpty {
                return 1
            }
            if contacts.count <= 3 {
                return contacts.count + 1
            }
        }
        
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCellId", for: indexPath) as! ContactTableViewCell
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 && isEditable!(){// && contacts.count < 3 {
            cell.textLabel?.text = "Add Contact"
            cell.imageView?.image = UIImage.init(named: "smallPlus")
            cell.imageView?.contentMode = UIViewContentMode.center
        }
        else if indexPath.row < tableView.numberOfRows(inSection: indexPath.section)-1 {
            let entry = contacts[indexPath.row]
            cell.configureWithContactEntry(entry)
            cell.layoutIfNeeded()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isEditable!() {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {
                return false
            }
            return true
        }
        return false
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 && contacts.count < 3{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            tableView.beginUpdates()
            self.contacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.endUpdates()
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    

}
