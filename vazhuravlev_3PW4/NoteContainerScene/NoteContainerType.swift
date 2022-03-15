//
//  NoteContainerType.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import Foundation

// Type of NoteContainerViewController
enum NoteContainerType {
    case allNotes
    case linkedNotes(Note)
    case linkNote(Note)
}
