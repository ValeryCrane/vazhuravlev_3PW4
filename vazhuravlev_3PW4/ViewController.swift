//
//  ViewController.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var emptyCollectionLabel: UILabel!
    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    // Current notes.
    public var notes: [Note] = [] {
        didSet {
            emptyCollectionLabel.isHidden = (notes.count != 0)
            notesCollectionView.reloadData()
        }
    }
    
    // CoreData MOC.
    public let context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "CoreDataNotes")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Container loading failed")
            }
        }
        return container.viewContext
    }()
    
    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(self.createNode))
    }
    
    
    // Opens NoteViewController to create new note.
    @objc private func createNode() {
        guard let noteViewController =
                storyboard?.instantiateViewController(
                    identifier: "NoteViewController") as? NoteViewController else { return }
        
        noteViewController.delegate = self
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    
    // MARK: - CoreData functions
    private func loadData() {
        if let notes = try? context.fetch(Note.fetchRequest()) as? [Note] {
            self.notes = notes.sorted(
                by: {$0.creationDate.compare($1.creationDate) == .orderedDescending})
        } else {
            self.notes = []
        }
    }
    
    func saveChanges() {
        if context.hasChanges {
            try? context.save()
        }
        loadData()
    }
}


// MARK: - UICollectionViewDataSource implementation
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.notes.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NoteCell", for: indexPath) as! NoteCell
        let note = notes[indexPath.row]
        cell.titleLabel.text = note.title
        cell.descriptionLabel.text = note.descriptionText
        return cell
    }
}


// MARK: - UICollectionViewDelegate implementation
extension ViewController: UICollectionViewDelegate {
    // Adding ability to delete notes vie context menu (on long tap).
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = "\(indexPath.row)" as NSString
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: .none) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: UIMenuElement.Attributes.destructive) { value in
                self.context.delete(self.notes[indexPath.row])
                self.saveChanges()
            }
            return UIMenu(title: "", image: nil, children: [deleteAction])
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout implementation
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 150)
    }
}
