//
//  EditNoteViewController.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import Foundation
import UIKit

class EditNoteViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    public var noteToEdit: Note?
    
    private let noteWorker = CoreDataNoteWorker()
    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let note = noteToEdit {
            self.title = "Edit note"
            titleTextField.text = note.title
            textView.text = note.descriptionText
        } else {
            self.title = "Add note"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.saveNote))
        
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Note title",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
    }
    
    // MARK: - close functions
    // Saves note and closes NoteContainerViewController.
    @objc private func saveNote() {
        let title = titleTextField.text ?? ""
        let description = textView.text ?? ""
        if !title.isEmpty {
            if let note = self.noteToEdit {
                noteWorker.change(note: note, title: title, description: description)
            } else {
                noteWorker.addNote(title: title, descriptionText: description)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}
