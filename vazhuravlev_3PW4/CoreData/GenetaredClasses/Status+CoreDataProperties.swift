//
//  Status+CoreDataProperties.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 16.03.2022.
//
//

import Foundation
import CoreData


extension Status {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Status> {
        return NSFetchRequest<Status>(entityName: "Status")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension Status {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
