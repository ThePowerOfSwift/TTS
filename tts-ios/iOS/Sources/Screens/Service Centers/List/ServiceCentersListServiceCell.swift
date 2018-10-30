//
//  ServiceCentersListServiceCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 17/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

final class ServiceCentersListServiceCell: TableViewCollectionViewCell {
    
    @IBOutlet private var serviceCenterImageView: UIImageView!
    @IBOutlet private var serviceCenterTextLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    
    func setImage(_ image: URL?, address: String?, brands: [URL]?) {
        serviceCenterImageView.image = nil
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        if let image = image {
            serviceCenterImageView.af_setImage(withURL: image, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: serviceCenterImageView.bounds.size, radius: serviceCenterImageView.bounds.midX))
        }
        
        for image in brands ?? [] {
            let height = stackView.bounds.height
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
            imageView.af_setImage(withURL: image, filter: AspectScaledToFitSizeFilter(size: imageView.bounds.size))
            imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: height).isActive = true
            stackView.addArrangedSubview(imageView)
        }
            
        serviceCenterTextLabel.text = address
    }
    
    // MARK: - Collection View
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorColor = UIColor(r: 56, g: 65, b: 88)
        selectionStyle = .gray
    }
    
}
