//
//  ContactsTableViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 01.12.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit


class ContactsTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    var complition: ((ContactEntry) -> Void)?
    let contacts = ContactsClass()
    var sectionsArray = [SectionClass]()
    // MARK: -

    
    override func viewDidLoad() {
        super.viewDidLoad()
        contacts.requestAccessToContacts { (success) in
            if success {
                self.contacts.retrieveContacts({ (success, contacts) in
                    if success && contacts!.count > 0 {
                        self.contacts.allContacts = contacts!
//                        сортировка по фамилии
                        self.contacts.allContacts.sort(by: { (obj1:ContactEntry, obj2:ContactEntry) -> Bool in
                            if obj1.surName!.isEmpty {
                                return obj1.surName > obj2.surName!
                            }
                            return obj1.surName < obj2.surName!
                        })
                        self.sectionsArray = self.contacts.getSectionsArray(withFilter: self.searchBar.text)!
                        
                        DispatchQueue.main.async {
                            
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
    }

    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionsArray[section].sectionName
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var indexTitles = [String]()
        for section in self.sectionsArray {
            let sectionName = section.sectionName
            indexTitles.append(sectionName!)
        }
        return indexTitles
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionsArray[section].sectionItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        let section = self.sectionsArray[indexPath.section]
        let entry = section.sectionItems[indexPath.row]
        cell.configureWithContactEntry(entry)
        cell.layoutIfNeeded()
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.resignFirstResponder()
        
        let section = self.sectionsArray[indexPath.section]
        let entry = section.sectionItems[indexPath.row]
        complition!(entry)
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.sectionsArray = self.contacts.getSectionsArray(withFilter: searchText)!
        self.tableView.reloadData()
    }
}
