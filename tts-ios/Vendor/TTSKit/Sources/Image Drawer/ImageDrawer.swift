//
//  ImageDrawer.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/07/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public final class ImageDrawer {
    
    let cache: ImageCache
    
    public static let `default` = ImageDrawer(cache: AutoPurgingImageCache())
    
    public init(cache: ImageCache) {
        self.cache = cache
    }
    
    public func draw(_ drawable: Drawable, in rect: CGRect) -> UIImage {
        let identifier = drawable.cacheIdentifier(forImageInRect: rect)
        
        if let cachedImage = cache.image(withIdentifier: identifier) {
            return cachedImage
        }
        
        let image = UIImage.image(size: rect.size) { _ in
            return drawable.draw(in: rect)
        }
        
        cache.add(image, withIdentifier: identifier)
        
        return image
    }
    
}
