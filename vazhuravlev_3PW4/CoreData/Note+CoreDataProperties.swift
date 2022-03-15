//
//  Note+CoreDataProperties.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var descriptionText: String?
    @NSManaged public var title: String?

}

extension Note : Identifiable {

}
