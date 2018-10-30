//
//  GarageMainTechServiceRecordCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class GarageMainTechServiceRecordCell: UICollectionViewCell, NibLoadable, HeightCalculatable {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    var item: GarageMainTechServiceRecordItem? {
        didSet {
            titleLabel.text = item.flatMap {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.ru_RU
                dateFormatter.dateFormat = "dd MMMM 'в 'HH:mm"
                return "Ждем " + dateFormatter.string(from: $0.record.period.lowerBound)
            }
            
            textLabel.text = item.flatMap { $0.record.service.address }
            
            backgroundColor = item?.backgroundColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIImageView()
        selectedBackgroundView = UIImageView()
    }
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let color = UIColor(r: 0, g: 148, b: 213)
        let radius: CGFloat = 8

        if let imageView = backgroundView as? UIImageView {
            let image = BezierPathImage(fillColor: color, corners: [.topLeft, .topRight], radius: radius)
            imageView.image = ImageDrawer.default.draw(image, in: imageView.bounds).resizableImage(withCapInsets: UIEdgeInsets(horizontal: radius, vertical: 0))
        }
        
        if let imageView = selectedBackgroundView as? UIImageView {
            let image = BezierPathImage(fillColor: color.brightening(by: 0.2), corners: [.topLeft, .topRight], radius: radius)
            imageView.image = ImageDrawer.default.draw(image, in: imageView.bounds).resizableImage(withCapInsets: UIEdgeInsets(horizontal: radius, vertical: 0))
        }

    }
    
}
