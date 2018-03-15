//
//  PlaceCoordinate+CoreDataProperties.swift
//  
//
//  Created by Alexandr Polukhin on 22.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PlaceCoordinate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceCoordinate> {
        return NSFetchRequest<PlaceCoordinate>(entityName: "PlaceCoordinate");
    }

    @NSManaged public var isArrive: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var subTitle: String?
    @NSManaged public var title: String?
    @NSManaged public var radius: Int16
    @NSManaged public var notification: Notification?

}
