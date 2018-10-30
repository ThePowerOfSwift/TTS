//
//  HeightCalculatable.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

protocol HeightCalculatable {
    
    func height(forWidth width: CGFloat) -> CGFloat
    
}

extension Array where Element == HeightCalculatable {
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return reduce(0) { $0 + $1.height(forWidth: width) }
    }
    
}

extension HeightCalculatable where Self: UICollectionViewCell {

    func height(forWidth width: CGFloat) -> CGFloat {
        frame.size.width = width
        layoutIfNeeded()
        let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size.height
    }

}
