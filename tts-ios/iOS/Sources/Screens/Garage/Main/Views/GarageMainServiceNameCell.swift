//
//  GarageMainServiceNameCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class GarageMainServiceNameCell: UICollectionViewCell, NibLoadable, HeightCalculatable {

    @IBOutlet private var nameLabel: UILabel!
    
    var item: GarageMainServiceNameItem? {
        didSet {
            nameLabel.text = item?.name
            backgroundColor = item?.backgroundColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIImageView()
    }
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = backgroundView as? UIImageView {
            let image = BezierPathImage(fillColor: UIColor(r: 37, g: 42, b: 57), corners: [.topLeft, .topRight], radius: 8)
            imageView.image = ImageDrawer.default.draw(image, in: imageView.bounds)
        }
    }
    
}
