//
//  ServiceCenterImageCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

class ServiceCenterImageCell: UICollectionViewCell, NibLoadable {

    @IBOutlet private var imageView: UIImageView!

    var image: URL? {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layoutIfNeeded()
        imageView.image = nil
        if let image = image {
            imageView.af_setImage(withURL: image, filter: AspectScaledToFillSizeFilter(size: imageView.bounds.size))
        }
    }
    
}
