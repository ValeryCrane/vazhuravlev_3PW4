//
//  NoteContainerRouter.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import Foundation
import UIKit

protocol NoteContainerRoutingLogic {
    func routeToCreateNote()                // Opens note creation scene.
    func routeToEditNote(note: Note)        // Opens note edition scene.
    func routeToLinkedNotes(note: Note)     // Opens note links scene.
    func routeToLinkNote(note: Note)        // Opens note links addition scene.
    func routeBack()                        // Closes top view in navigation.
}

class NoteContainerRouter {
    public weak var view: UIViewController!
}


// MARK: - NoteContainerRoutingLogic implementation
extension NoteContainerRouter: NoteContainerRoutingLogic {
    func routeToCreateNote() {
        guard let noteViewController = view.storyboard?.instantiateViewController(
                    identifier: "NoteViewController") as? EditNoteViewController
        else { return }
        
        view.navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    func routeToEditNote(note: Note) {
        guard let noteViewController = view.storyboard?.instantiateViewController(
                    identifier: "NoteViewController") as? EditNoteViewController
        else { return }
        
        noteViewController.noteToEdit = note
        view.navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    func routeToLinkedNotes(note: Note) {
        guard let noteContainer = view.storyboard?.instantiateViewController(
                identifier: "NoteContainerViewController") as? NoteContainerViewController
        else { return }
        
        noteContainer.noteContainerType = .linkedNotes(note)
        view.navigationController?.pushViewController(noteContainer, animated: true)
    }
    
    func routeToLinkNote(note: Note) {
        guard let noteContainer = view.storyboard?.instantiateViewController(
                identifier: "NoteContainerViewController") as? NoteContainerViewController
        else { return }
        noteContainer.noteContainerType = .linkNote(note)
        view.navigationController?.pushViewController(noteContainer, animated: true)
    }
    
    func routeBack() {
        view.navigationController?.popViewController(animated: true)
    }
}
