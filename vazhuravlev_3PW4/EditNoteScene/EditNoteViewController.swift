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
    @IBOutlet weak var statusPicker: UIPickerView!
    
    public var noteToEdit: Note?
    
    private var statuses = ["new", "waiting", "done"]
    
    private let noteWorker = CoreDataNoteWorker()
    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let note = noteToEdit {
            self.title = "Edit note"
            titleTextField.text = note.title
            textView.text = note.descriptionText
            statusPicker.selectRow(Int(note.status), inComponent: 0, animated: false)
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
        let status = NoteStatus(rawValue: Int32(statusPicker.selectedRow(inComponent: 0)))
        if !title.isEmpty, let status = status {
            if let note = self.noteToEdit {
                noteWorker.change(note: note, title: title, description: description, status: status)
            } else {
                noteWorker.addNote(title: title, descriptionText: description, status: status)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - UIPickerViewDataSource & Delegate implemetation
extension EditNoteViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        statuses.count
    }
}

extension EditNoteViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var color = UIColor()
        switch row {
        case 0: color = .green
        case 1: color = .cyan
        case 2: color = .magenta
        default: color = .white
        }
        return NSAttributedString(string: self.statuses[row], attributes:
                            [NSAttributedString.Key.foregroundColor: color])
    }
}
