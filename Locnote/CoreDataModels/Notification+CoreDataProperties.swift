//
//  Notification+CoreDataProperties.swift
//  
//
//  Created by Alexandr Polukhin on 21.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Notification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification");
    }

    @NSManaged public var complitionDate: NSDate?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var isFinished: Bool
    @NSManaged public var id: String?
    @NSManaged public var message: Message?
    @NSManaged public var placeLocation: PlaceCoordinate?

}
