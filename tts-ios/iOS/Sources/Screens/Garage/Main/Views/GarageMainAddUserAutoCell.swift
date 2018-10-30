//
//  GarageMainAddUserAutoCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class GarageMainAddUserAutoCell: UICollectionViewCell {

    @IBOutlet var textLabel: UILabel!
    @IBOutlet var button: UIButton!
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let color = button.titleColor(for: .normal) {
            let stroke = BezierPathImage.Stroke(color: color, style: .line, lineWidth: 2)
            let image = BezierPathImage(fillColor: .clear, stroke: stroke, radius: button.bounds.midY)
            button.setBackgroundImage(ImageDrawer.default.draw(image, in: button.bounds), for: .normal)
        }
    }

}
