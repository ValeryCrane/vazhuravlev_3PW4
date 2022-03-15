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
    
    public var notes: [Note] = [] {
        didSet {
            emptyCollectionLabel.isHidden = (notes.count != 0)
            notesCollectionView.reloadData()
        }
    }
    
    public let context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "CoreDataNotes")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Container loading failed")
            }
        }
        return container.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(self.createNode))
        // Do any additional setup after loading the view.
    }
    
    @objc private func createNode() {
        guard let noteViewController =
                storyboard?.instantiateViewController(
                    identifier: "NoteViewController") as? NoteViewController else { return }
        
        noteViewController.delegate = self
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
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

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 150)
    }
}
