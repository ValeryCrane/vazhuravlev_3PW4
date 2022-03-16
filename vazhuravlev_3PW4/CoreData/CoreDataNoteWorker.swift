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
    // Initializing context
    private static let context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "CoreDataNotes")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Container loading failed")
            }
        }
        return container.viewContext
    }()
    
    // Method saves changes in context.
    private func saveChanges() {
        if CoreDataNoteWorker.context.hasChanges {
            try? CoreDataNoteWorker.context.save()
        }
    }
    
    // Method gets all notes sorted by creation date.
    public func getNotes() -> [Note] {
        if let notes = try? CoreDataNoteWorker.context.fetch(Note.fetchRequest()) as? [Note] {
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
        note.status = status.rawValue
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
        if let status = status {
            note.status = status.rawValue
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
