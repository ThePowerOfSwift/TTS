//
//  ClusterIconGenerator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 27/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class ClusterIconGenerator: NSObject, GMUClusterIconGenerator {
    
    private let cache = NSCache<NSString, UIImage>()
    
    func icon(forSize size: UInt) -> UIImage! {
        return icon(forSize: numericCast(size), fillColor: .white, applyMinRectDimension: true)
    }
    
    func icon(forSize size: Int, fillColor: UIColor?, applyMinRectDimension: Bool) -> UIImage {
        let text = String(size)
        let cacheKey = (text + String(describing: fillColor) + String(describing: applyMinRectDimension)) as NSString
        if let image = cache.object(forKey: cacheKey) {
            return image
        }
        
        let attributes = StringAttributes {
            $0.font = UIFont.boldSystemFont(ofSize: 17)
            $0.alignment = .center
        }
        let attributedText = text.with(attributes)
        let textSize = attributedText.size()

        var rectDimension = max(ceil(textSize.width), ceil(textSize.height))
        if applyMinRectDimension {
            rectDimension = max(32, rectDimension) + 6
        }
        let rect = CGRect(x: 0, y: 0, width: rectDimension, height: rectDimension)
        
        let image = UIGraphicsImageRenderer(size: rect.size).image { context in
            if let fillColor = fillColor {
                fillColor.setFill()
                context.cgContext.fillEllipse(in: rect)
            }
            
            UIColor.darkText.set()
            let textRect = rect.insetBy(dx: (rect.width - textSize.width) / 2, dy: (rect.height - textSize.height) / 2)
            attributedText.draw(in: textRect.integral)
        }
        
        cache.setObject(image, forKey: cacheKey)
        return image
    }
    
}
