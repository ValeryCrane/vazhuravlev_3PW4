//
//  NoteCell.swift
//  vazhuravlev_3PW4
//
//  Created by Валерий Журавлев on 15.03.2022.
//

import Foundation
import UIKit

// View, representing a note in collection view.
class NoteCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

