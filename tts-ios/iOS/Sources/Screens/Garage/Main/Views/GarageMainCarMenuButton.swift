//
//  GarageMainCarMenuButton.swift
//  tts
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

@IBDesignable
final class GarageMainCarMenuButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = imageView, let titleLabel = titleLabel else { return }
        
        imageView.frame = CGRect(x: round(bounds.midX - imageView.bounds.midX), y: max(0, round(bounds.midY - imageView.bounds.height)), width: imageView.bounds.width, height: imageView.bounds.height)

        let y = imageView.frame.maxY + imageEdgeInsets.bottom
        let titleLabelSize = titleLabel.sizeThatFits(bounds.size)
        titleLabel.frame = CGRect(x: round(bounds.midX - titleLabelSize.width / 2), y: y, width: titleLabelSize.width, height: titleLabelSize.height)
    }
    
}
