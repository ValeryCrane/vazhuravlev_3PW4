//
//  NoteViewController.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    public weak var delegate: ViewController! // Link to main ViewController
    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.saveNote))
    }
    
    // Saves note and closes ViewController.
    @objc private func saveNote() {
        let title = titleTextField.text ?? ""
        let description = textView.text ?? ""
        if !title.isEmpty {
            let note = Note(context: delegate.context)
            note.title = title
            note.descriptionText = description
            note.creationDate = Date()
            delegate.saveChanges()
        }
        self.navigationController?.popViewController(animated: true)
    }
}
