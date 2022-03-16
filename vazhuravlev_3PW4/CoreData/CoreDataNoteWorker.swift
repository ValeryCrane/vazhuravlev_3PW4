//
//  CoreDataNoteWorker.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import Foundation
import CoreData

// Class, which works with CoreData viewContext.
class CoreDataNoteWorker {
    public static let storeName = "CoreDataNotes"
    
    // MARK: - Private setup & save functions
    // Initializing context
    private static let context: NSManagedObjectContext = {
        // Creating persistantStore description.
        let description: NSPersistentStoreDescription = {
            if let storeURL = CoreDataNoteWorker.getStoreURL() {
                return NSPersistentStoreDescription(url: storeURL)
            }
            return NSPersistentStoreDescription()
        }()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = false
        
        // Creationg persistantContainer, loadingStores and returning context.
        let container = NSPersistentContainer(name: CoreDataNoteWorker.storeName)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Container loading failed")
            }
        }
        CoreDataNoteWorker.setupStatusValues(context: container.viewContext)
        return container.viewContext
    }()
    
    
    // Creates URL of CoreData store file.
    private static func getStoreURL() -> URL? {
        let fileManager = FileManager.default
        let storePath = try? fileManager.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask, appropriateFor: nil, create: true)
        let sqliteFilePath = storePath?.appendingPathComponent(CoreDataNoteWorker.storeName + ".sqlite")
        return sqliteFilePath
    }
    
    
    // Setups statuses in case there are no statuses in the store
    // (if app is new or migration didn't have enough statuses as samples from notes).
    private static func setupStatusValues(context: NSManagedObjectContext) {
        for statusId in 0..<3 {
            let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", statusId)
            
            guard let statuses = try? context.fetch(fetchRequest), statuses.count != 0 else {
                print("New status with id: \(statusId)")
                let newStatus = Status(context: context)
                
                newStatus.id = Int32(statusId)
                switch statusId {
                case 0: newStatus.title = "new"
                case 1: newStatus.title = "waiting"
                case 2: newStatus.title = "done"
                default: newStatus.title = "unknown"
                }
                
                try? context.save()
                continue
            }
        }
    }
    
    
    // Method saves changes in context.
    private func saveChanges() {
        if CoreDataNoteWorker.context.hasChanges {
            try? CoreDataNoteWorker.context.save()
        }
    }
    
    
    // MARK: - public functions
    // Gets status by NoteStatus enum.
    public func getStatus(status: NoteStatus?) -> Status? {
        guard let status = status else { return nil }
        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", status.rawValue)
        
        let statuses = try? CoreDataNoteWorker.context.fetch(fetchRequest) as [Status]
        if let statuses = statuses, statuses.count != 0 {
            return statuses[0]
        }
        return nil
    }
    
    
    // Return list of all statuses available.
    public func getStatuses() -> [Status] {
        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        let statuses = try? CoreDataNoteWorker.context.fetch(fetchRequest) as [Status]
        return statuses ?? []
    }
    
    
    // Method gets all notes sorted by creation date.
    public func getNotes() -> [Note] {
        let notes = try? CoreDataNoteWorker.context.fetch(Note.fetchRequest()) as? [Note]
        if let notes = notes {
            return notes.sorted(
                by: {$0.creationDate.compare($1.creationDate) == .orderedDescending})
        }
        return []
    }
    
    
    // Method add note via context.
    public func addNote(title: String, descriptionText: String, status: NoteStatus) {
        let note = Note(context: CoreDataNoteWorker.context)
        note.title = title
        note.descriptionText = descriptionText
        note.creationDate = Date()
        if let fetchedStatus = getStatus(status: status) {
            note.status = fetchedStatus
        }
        self.saveChanges()
    }
    
    
    // Method deletes note via context.
    public func deleteNote(note: Note) {
        CoreDataNoteWorker.context.delete(note)
        self.saveChanges()
    }
    
    
    // Method add note via context.
    public func change(note: Note, title: String?, description: String?, status: NoteStatus?) {
        note.title = title
        note.descriptionText = description
        if let fetchedStatus = getStatus(status: status) {
            note.status = fetchedStatus
        }
        self.saveChanges()
    }
    
    
    // Method links two notes via context.
    public func connectNotes(first: Note, second: Note) {
        first.addToLinks(second)
        self.saveChanges()
    }
    
    
    // Method breaks link between notes via context.
    public func disconnectNotes(first: Note, second: Note) {
        first.removeFromLinks(second)
        self.saveChanges()
    }
}
