//
//  OrderTechServiceVariantCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

class OrderTechServiceVariantCell: UICollectionViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var fromLabel: UILabel!
    @IBOutlet private var toLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    
    var item: OrderTechServiceVariantItem? {
        didSet {
            indexLabel.text = item.flatMap { "Вариант №\($0.index + 1)" }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.ru_RU
            dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM y")

            let timeFormatter = TimeFormatter()
            let durationFormatter = DurationFormatter()
            durationFormatter.calendar = Calendar.autoupdatingCurrent
            durationFormatter.calendar?.locale = Locale.ru_RU
            
            dateLabel.text = item.flatMap { dateFormatter.string(from: $0.variant.range.lowerBound) }
            fromLabel.text = item.flatMap { timeFormatter.string(from: $0.variant.range.lowerBound) }
            toLabel.text = item.flatMap { timeFormatter.string(from: $0.variant.range.upperBound) }
            durationLabel.text = item.flatMap { durationFormatter.string(from: $0.variant.range) }
            
            if item?.isSelected ?? false {
                containerView.backgroundColor = UIColor(r: 57, g: 65, b: 88)
            } else {
                containerView.backgroundColor = UIColor(r: 42, g: 50, b: 68)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 8
    }
    
}
