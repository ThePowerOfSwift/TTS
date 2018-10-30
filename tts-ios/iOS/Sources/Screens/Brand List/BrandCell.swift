//
//  BrandCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

final class BrandCell: UITableViewCell, NibLoadable {
    
    @IBOutlet private var brandImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    var item: CarBrand? {
        didSet {
            brandImageView.image = nil
            if let image = item?.image {
                brandImageView.af_setImage(withURL: image, filter: AspectScaledToFitSizeFilter(size: brandImageView.bounds.size))
            } else {
                brandImageView.af_cancelImageRequest()
            }
            titleLabel.text = item?.name
        }
    }
    
}
