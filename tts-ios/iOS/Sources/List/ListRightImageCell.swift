//
//  ListRightImageCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class ListRightImageCell: TableViewCollectionViewCell {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    var item: ListRightImageItem? {
        didSet {
            imageView.image = item?.image
            titleLabel.text = item?.text
            titleLabel.font = item?.font
            if let textColor = item?.textColor {
                titleLabel.textColor = textColor
            }
            backgroundColor = item?.backgroundColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorStyle = .none
        selectionStyle = .gray
    }

}
