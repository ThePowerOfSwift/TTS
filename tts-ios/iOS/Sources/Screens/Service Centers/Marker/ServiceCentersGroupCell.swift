//
//  ServiceCentersGroupCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 05/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

class ServiceCentersGroupCell: TableViewCollectionViewCell, NibLoadable {
    
    @IBOutlet private var stackView: UIStackView!
    
    var item: ServiceCentersGroupItem? {
        didSet {
            stackView.arrangedSubviews.forEach {$0.removeFromSuperview()}
            separatorStyle = item?.separatorStyle ?? .none
            
            item?.group.services.forEach {
                guard let imageURL = $0.brandImage else { return }
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                imageView.af_setImage(withURL: imageURL, filter: AspectScaledToFitSizeFilter(size: imageView.bounds.size))
                stackView.addArrangedSubview(imageView)
            }
            apply(background: item?.background)
            setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorColor = UIColor(r: 57, g: 65, b: 88)
        selectionStyle = .none
    }
    
}
