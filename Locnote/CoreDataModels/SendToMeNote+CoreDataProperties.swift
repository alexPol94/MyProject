//
//  SendToMeNote+CoreDataProperties.swift
//  
//
//  Created by Alexandr Polukhin on 04.02.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension SendToMeNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SendToMeNote> {
        return NSFetchRequest<SendToMeNote>(entityName: "SendToMeNote");
    }

    @NSManaged public var audioMessages: NSSet?
    @NSManaged public var contacts: NSSet?
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for audioMessages
extension SendToMeNote {

    @objc(addAudioMessagesObject:)
    @NSManaged public func addToAudioMessages(_ value: AudioMessage)

    @objc(removeAudioMessagesObject:)
    @NSManaged public func removeFromAudioMessages(_ value: AudioMessage)

    @objc(addAudioMessages:)
    @NSManaged public func addToAudioMessages(_ values: NSSet)

    @objc(removeAudioMessages:)
    @NSManaged public func removeFromAudioMessages(_ values: NSSet)

}

// MARK: Generated accessors for contacts
extension SendToMeNote {

    @objc(addContactsObject:)
    @NSManaged public func addToContacts(_ value: Contact)

    @objc(removeContactsObject:)
    @NSManaged public func removeFromContacts(_ value: Contact)

    @objc(addContacts:)
    @NSManaged public func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged public func removeFromContacts(_ values: NSSet)

}

// MARK: Generated accessors for photos
extension SendToMeNote {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
