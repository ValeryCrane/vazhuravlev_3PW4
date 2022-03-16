//
//  Note+CoreDataProperties.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 16.03.2022.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var creationDate: Date
    @NSManaged public var status: Int32
    @NSManaged public var links: NSSet?

}

// MARK: Generated accessors for links
extension Note {

    @objc(addLinksObject:)
    @NSManaged public func addToLinks(_ value: Note)

    @objc(removeLinksObject:)
    @NSManaged public func removeFromLinks(_ value: Note)

    @objc(addLinks:)
    @NSManaged public func addToLinks(_ values: NSSet)

    @objc(removeLinks:)
    @NSManaged public func removeFromLinks(_ values: NSSet)

}

extension Note : Identifiable {

}
