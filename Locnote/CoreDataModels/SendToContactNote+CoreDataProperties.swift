//
//  SendToContactNote+CoreDataProperties.swift
//  
//
//  Created by Alexandr Polukhin on 04.02.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension SendToContactNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SendToContactNote> {
        return NSFetchRequest<SendToContactNote>(entityName: "SendToContactNote");
    }

    @NSManaged public var contact: Contact?

}
