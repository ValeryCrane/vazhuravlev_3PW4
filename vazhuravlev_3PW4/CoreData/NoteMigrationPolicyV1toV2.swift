//
//  NoteMigrationPolicyV1toV2.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 16.03.2022.
//
 
import Foundation
import CoreData
 
class NoteMigrationPolicyV1toV2: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        // Making migrations from xcmappingmodel file.
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        // Getting statusId value from Note.
        let noteStatus = sInstance.value(forKey: "status") as? Int32 ?? 0
        
        // Finding status with given id
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Status")
        fetchRequest.predicate = NSPredicate(format: "id == %d", noteStatus)
        let fetchedStatus = try manager.destinationContext.fetch(fetchRequest)
        
        var status: NSManagedObject?
        
        if fetchedStatus.count != 0 {
            // If status was found, use it.
            status = fetchedStatus[0]
        } else {
            // Else create in in destination context.
            let statusEntity =
                NSEntityDescription.entity(forEntityName: "Status",
                                           in: manager.destinationContext)!
            let createdStatus = NSManagedObject(
                entity: statusEntity,
                insertInto: manager.destinationContext
            )
            createdStatus.setValue(noteStatus, forKey: "id")
            switch noteStatus {
            case 0: createdStatus.setValue("new", forKey: "title")
            case 1: createdStatus.setValue("waiting", forKey: "title")
            case 2: createdStatus.setValue("done", forKey: "title")
            default: break
            }
            status = createdStatus
        }
    
        // Creating reference from destionation note to destionation status.
        let destResults = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance])
        if let destinationNote = destResults.last,
           let status = status {
            destinationNote.setValue(status, forKey: "status")
        }
    }
}
