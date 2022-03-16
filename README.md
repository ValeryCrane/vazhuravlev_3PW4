#  Notes app

- The project contains NavigationController and CollectionView with cell.

- NavigationBar contains “add note” button.

- Pressing “add note” button opens “create note” screen.

- Create note screen contains done button on NavigationBar.

- Pressing “done” button creates new note and it shows on CollectionView.

- Keeping data about notes in CoreData.

- Note have relation with other notes using CoreData. Also, you can edit notes. And I made some refactoring.

- Added status property(done, waiting, new or others) with type Integer32 for Note entity on first version of CoreData model.
