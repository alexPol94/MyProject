//
//  Contact+CoreDataProperties.swift
//  
//
//  Created by Alexandr on 17.02.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact");
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phone: String?
    @NSManaged public var photo: NSData?
    @NSManaged public var sendToContactNote: SendToContactNote?
    @NSManaged public var sendToMeNote: SendToMeNote?

}
