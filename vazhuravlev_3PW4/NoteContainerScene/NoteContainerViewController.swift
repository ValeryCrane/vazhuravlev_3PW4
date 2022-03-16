//
//  NoteContainerViewController.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import UIKit
import CoreData

class NoteContainerViewController: UIViewController {
    public var noteContainerType = NoteContainerType.allNotes   // Type of ViewController.
    public var router: NoteContainerRoutingLogic!               // Router.
    
    @IBOutlet weak var emptyCollectionLabel: UILabel!           // Label for empty collection.
    @IBOutlet weak var notesCollectionView: UICollectionView!   // Collection with notes.
    
    private let noteWorker = CoreDataNoteWorker()               // CoreData worker
    
    public var notes: [Note] = [] {                             // Current notes.
        didSet {                                                // Updating views.
            emptyCollectionLabel.isHidden = (notes.count != 0)
            notesCollectionView.reloadData()
        }
    }
    
    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let router = NoteContainerRouter()
        self.router = router
        router.view = self
        setupTabBar()
        setupEmptyCollectionLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNotes()
    }
    
    
    // MARK: - setup functions
    private func setupTabBar() {
        switch noteContainerType {
        case .allNotes:
            self.title = "Notes"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add, target: self,
                action: #selector(self.createNote))
        case .linkedNotes:
            self.title = "Linked notes"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Add link", style: .plain, target: self,
                action: #selector(self.showAddSimilarNote))
        case .linkNote:
            self.title = "Add link"
        }
    }
    
    private func setupEmptyCollectionLabel() {
        switch noteContainerType {
        case .allNotes:
            emptyCollectionLabel.text = "No notes yet"
        case .linkedNotes:
            emptyCollectionLabel.text = "No linked notes"
        case .linkNote:
            emptyCollectionLabel.text = "No available notes to link"
        }
    }
    
    
    // MARK: - routing functions
    @objc private func createNote() {
        guard case .allNotes = self.noteContainerType else { return }
        router.routeToCreateNote()
    }
    
    @objc private func showAddSimilarNote() {
        guard case let .linkedNotes(note) = self.noteContainerType else { return }
        router.routeToLinkNote(note: note)
    }
    
    
    // MARK: - update functions
    // Updates notes via CoreData worker.
    private func updateNotes() {
        switch noteContainerType {
        case .allNotes:
            notes = noteWorker.getNotes()
        case .linkedNotes(let note):
            let linkedNotes = note.links?.allObjects as? [Note]
            notes = linkedNotes ?? []
        case .linkNote(let note):
            let linkedNotes = (note.links ?? NSSet())
            let notLinkedNotes = minus(
                firstSet: minus(firstSet: NSSet(array: noteWorker.getNotes()),
                                secondSet: linkedNotes),
                secondSet: NSSet(object: note)
            )
            notes = (notLinkedNotes.allObjects as? [Note]) ?? []
        }
    }
    
    // Returns firstSet without items in second set.
    private func minus(firstSet: NSSet, secondSet: NSSet) -> NSSet {
        return NSSet(array: firstSet.allObjects.filter { !secondSet.contains($0) })
    }
}


// MARK: - UICollectionViewDataSource implementation
extension NoteContainerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        self.notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NoteCell", for: indexPath) as! NoteCell
        let note = notes[indexPath.row]
        cell.titleLabel.text = note.title
        cell.descriptionLabel.text = note.descriptionText
        if let noteStatus = NoteStatus(rawValue: note.status) {
            switch noteStatus {
            case NoteStatus.new:
                cell.statusLabel.text = "new"
                cell.statusLabel.textColor = .green
            case NoteStatus.waiting:
                cell.statusLabel.text = "waiting"
                cell.statusLabel.textColor = .cyan
            case NoteStatus.done:
                cell.statusLabel.text = "done"
                cell.statusLabel.textColor = .magenta
            }
        }
        return cell
    }
}


// MARK: - UICollectionViewDelegate implementation
extension NoteContainerViewController: UICollectionViewDelegate {
    
    // Adding context menu with deletion and linking abilities.
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = "\(indexPath.row)" as NSString
        return UIContextMenuConfiguration(identifier: identifier,
                                          previewProvider: .none) { _ in
            return self.getContextMenuFor(indexPath: indexPath)
        }
    }
    
    // Creating context menu for index path depending on container type.
    private func getContextMenuFor(indexPath: IndexPath) -> UIMenu? {
        switch self.noteContainerType {
        case .allNotes:
            let deleteAction =
                UIAction(
                    title: "Delete",
                    image: UIImage(systemName: "trash"),
                    attributes: UIMenuElement.Attributes.destructive
                ) { _ in
                self.noteWorker.deleteNote(note: self.notes[indexPath.row])
                self.updateNotes()
            }
            let showSimilarNotesAction = UIAction(
                title: "Show linked notes",
                image: UIImage(named: "link")
            ) { _ in
                self.router.routeToLinkedNotes(note: self.notes[indexPath.row])
            }
            return UIMenu(title: "", image: nil, children: [showSimilarNotesAction,
                                                            deleteAction])
        case let .linkedNotes(note):
            let deleteAction = UIAction(
                title: "Delete from linked",
                image: UIImage(systemName: "trash"),
                attributes: UIMenuElement.Attributes.destructive)
            { value in
                self.noteWorker.disconnectNotes(first: self.notes[indexPath.row], second: note)
                self.updateNotes()
            }
            return UIMenu(title: "", image: nil, children: [deleteAction])
            
        case .linkNote:
            return nil
        }
    }
    
    // Adding links and note editing implementation.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.noteContainerType {
        case .allNotes:
            router.routeToEditNote(note: self.notes[indexPath.row])
        case let .linkNote(note):
            self.noteWorker.connectNotes(first: self.notes[indexPath.row], second: note)
            self.router.routeBack()
        default:
            return
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout implementation
extension NoteContainerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 140)
    }
}
