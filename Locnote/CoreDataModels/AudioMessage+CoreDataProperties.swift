//
//  AudioMessage+CoreDataProperties.swift
//  
//
//  Created by Alexandr Polukhin on 04.02.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension AudioMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioMessage> {
        return NSFetchRequest<AudioMessage>(entityName: "AudioMessage");
    }

    @NSManaged public var audio: NSData?
    @NSManaged public var note: SendToMeNote?

}
