//
//  GarageAutoArchiveButton.swift
//  tts
//
//  Created by Dmitry Nesterenko on 12/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

@IBDesignable
final class GarageAutoArchiveButton: SubmitButton {

    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = imageView, let titleLabel = titleLabel else { return }
        
        titleLabel.frame = CGRect(x: 16, y: round(bounds.midY - titleLabel.bounds.midY), width: titleLabel.bounds.width, height: titleLabel.bounds.height)
        imageView.frame = CGRect(x: bounds.maxX - imageView.bounds.width - 16, y: round(bounds.midY - imageView.bounds.midY), width: imageView.bounds.width, height: imageView.bounds.height)
    }

}
