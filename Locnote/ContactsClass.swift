//
//  ContactsClass.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 10.12.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit
import Contacts

class ContactsClass: NSObject {
    let contactStore = CNContactStore()
    var allContacts = [ContactEntry]()
    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized: completion(true)
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: {
                (accessGranted, error) -> Void in
                completion(accessGranted)
            })
        default:
            completion(false)
        }
    }
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [ContactEntry]?) -> Void) {
        var allContacts = [ContactEntry]()
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = ContactEntry(cnContact: cnContact) { allContacts.append(contact) }
            })
            completion(true, allContacts)
        } catch {
            completion(false, nil)
        }
    }
    
    func getSectionsArray(withFilter filter:String?) -> [SectionClass]? {
        
        var sectionsArray = [SectionClass]()
        var currentLetter = String()
        
        for contact in self.allContacts {
            let fullName = (contact.name + " " + contact.surName).lowercased()
            if !filter!.isEmpty && fullName.lowercased().range(of: filter!.lowercased()) == nil && contact.surName.lowercased().range(of: filter!.lowercased()) == nil  {
                continue
            }
            let lastName = contact.surName
            var firstLetter = lastName!.characters.first?.description
            if firstLetter == nil {
                firstLetter = "#"
            }
            var section = SectionClass()
            if currentLetter != firstLetter {
                section.sectionName = firstLetter
                currentLetter = firstLetter!
                sectionsArray.append(section)
            } else {
                section = sectionsArray.last!
            }
            section.sectionItems.append(contact)
        }
        
        return sectionsArray
    }

    
}
