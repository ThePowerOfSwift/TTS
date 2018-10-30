//
//  HistoryTreatmentCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import AlamofireImage
import TTSKit

final class HistoryTreatmentCell: TableViewCollectionViewCell {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var masterLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var orderLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .gray
        separatorColor = UIColor(r: 42, g: 47, b: 68)
    }
    
    var item: HistoryTreatmentItem? {
        didSet {
            if let url = item?.masterPhoto {
                imageView.af_setImage(withURL: url, filter: AspectScaledToFitSizeFilter(size: imageView.bounds.size))
            } else {
                imageView.af_cancelImageRequest()
                imageView.image = nil
            }
        
            masterLabel.text = item?.master
            dateLabel.text = item?.date
            priceLabel.text = item?.price
            orderLabel.text = item?.order
            textLabel.text = item?.reason
        }
    }

    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let item = item else { return }
        let layout = item.calculator.layout(for: bounds.width)
        dateLabel.frame = layout.dateLabelFrame
        dateLabel.font = item.calculator.dateLabelFont
        orderLabel.frame = layout.orderLabelFrame
        orderLabel.font = item.calculator.orderLabelFont
        textLabel.frame = layout.reasonLabelFrame
        textLabel.font = item.calculator.reasonLabelFont
    }
    
}
