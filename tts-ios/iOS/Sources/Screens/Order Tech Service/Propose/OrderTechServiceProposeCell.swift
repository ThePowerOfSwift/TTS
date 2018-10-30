//
//  OrderTechServiceProposeCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

final class OrderTechServiceProposeCell: TableViewCollectionViewCell, NibLoadable, HeightCalculatable {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var rightDetailLabel: UILabel!

    var item: OrderTechServiceProposeItem? {
        didSet {
            titleLabel.text = item?.title
            subtitleLabel.text = item?.subtitle
            rightDetailLabel.text = item?.rightDetailTitle
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        separatorColor = UIColor(r: 57, g: 65, b: 88)
    }
    
}
