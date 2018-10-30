//
//  ServiceCentersListMyCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

/// Ячейка для списка "Мои Сервисы" на экране "Сервисные цетры/Список" `ServiceCentersListMyServicesCell`
final class ServiceCentersListMyCell: UICollectionViewCell, NibLoadable {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var serviceCenterImageView: UIImageView!
    @IBOutlet private var serviceCenterTitleLabel: UILabel!
    @IBOutlet private var autoImageView: UIImageView!
    @IBOutlet private var autoTitleLabel: UILabel!
    
    var pair: ServiceCenterUserAutoLightPair? {
        didSet {
            if let service = pair?.service {
                serviceCenterImageView.image = nil
                serviceCenterImageView.af_setImage(withURL: service.image, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: serviceCenterImageView.bounds.size, radius: serviceCenterImageView.bounds.midX))
                serviceCenterTitleLabel.text = service.address
            } else {
                serviceCenterImageView.image = nil
                serviceCenterTitleLabel.text = nil
            }

            if let auto = pair?.auto {
                autoImageView.image = nil
                autoImageView.af_setImage(withURL: auto.image, filter: AspectScaledToFitSizeFilter(size: autoImageView.bounds.size))
                autoTitleLabel.text = auto.brand
            } else {
                autoImageView.image = nil
                autoTitleLabel.text = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 4
        updateSelectionAndHighlighting()
    }
    
    // MARK: - Managing Cell Selection and Highlighting
    
    override var isSelected: Bool {
        didSet {
            updateSelectionAndHighlighting()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateSelectionAndHighlighting()
        }
    }
    
    private func updateSelectionAndHighlighting() {
        let backgroundColor = UIColor(r: 56, g: 65, b: 88)
        if isSelected || isHighlighted {
            containerView.backgroundColor = backgroundColor.brightening(by: 0.1)
        } else {
            containerView.backgroundColor = backgroundColor
        }
    }
    
}
