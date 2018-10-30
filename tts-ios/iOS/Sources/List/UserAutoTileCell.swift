//
//  UserAutoTileCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 13/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

final class UserAutoTileCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIImageView()
        selectedBackgroundView = UIImageView()
    }
    
    var item: UserAutoTileItem? {
        didSet {
            if let auto = item?.auto {
                imageView.af_setImage(withURL: auto.image, filter: AspectScaledToFitSizeFilter(size: CGSize(width: 110, height: 80)))
            } else {
                imageView.af_cancelImageRequest()
                imageView.image = #imageLiteral(resourceName: "car_silhouette")
            }
            textLabel.text = item?.auto.brand
        }
    }

    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = backgroundView as? UIImageView {
            let image = BezierPathImage(fillColor: UIColor(r: 45, g: 52, b: 69), radius: 4)
            imageView.image = ImageDrawer.default.draw(image, in: imageView.bounds)
        }
        
        if let imageView = selectedBackgroundView as? UIImageView {
            let image = BezierPathImage(fillColor: UIColor(r: 65, g: 72, b: 89), radius: 4)
            imageView.image = ImageDrawer.default.draw(image, in: imageView.bounds)
        }
    }
    
}
