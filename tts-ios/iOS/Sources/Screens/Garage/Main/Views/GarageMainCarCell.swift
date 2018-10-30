//
//  GarageMainCarCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

final class GarageMainCarCell: UICollectionViewCell {

    @IBOutlet private var carImageView: UIImageView!
    @IBOutlet var serviceButton: UIButton!
    @IBOutlet var repairButton: UIButton!
    @IBOutlet var priceButton: UIButton!
    
    var item: GarageMainCarItem? {
        didSet {
            if let auto = item?.auto {
                carImageView.af_setImage(withURL: auto.image, filter: AspectScaledToFitSizeFilter(size: CGSize(width: 210, height: 160)))
                serviceButton.isEnabled = true
                repairButton.isEnabled = true
                priceButton.isEnabled = true
            } else {
                carImageView.af_cancelImageRequest()
                carImageView.image = #imageLiteral(resourceName: "car_silhouette")
                serviceButton.isEnabled = false
                repairButton.isEnabled = false
                priceButton.isEnabled = false
            }
        }
    }
    
}
