//
//  ListButtonCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

final class ListButtonCell: TableViewCollectionViewCell, NibLoadable {
    
    @IBOutlet var labelContainerView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var accessoryView: UIView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.preservesSuperviewLayoutMargins = preservesSuperviewLayoutMargins
        selectionStyle = .none
        separatorInset = .zero
        separatorColor = UIColor(r: 57, g: 65, b: 88)
    }
    
}
