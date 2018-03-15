//
//  Message+CoreDataProperties.swift
//  
//
//  Created by Alexandr Polukhin on 04.02.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var attributedText: NSData?
    @NSManaged public var text: String?
    @NSManaged public var notification: Notification?

}
