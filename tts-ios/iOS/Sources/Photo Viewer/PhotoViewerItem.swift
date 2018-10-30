//
//  PhotoViewerItem.swift
//  tts
//
//  Created by Dmitry Nesterenko on 27/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import NYTPhotoViewer
import AlamofireImage

final class PhotoViewerItem: NSObject, NYTPhoto {
    
    var image: UIImage?
    
    var imageData: Data?
    
    var placeholderImage: UIImage?
    
    var attributedCaptionTitle: NSAttributedString?
    
    var attributedCaptionSummary: NSAttributedString?
    
    var attributedCaptionCredit: NSAttributedString?
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PhotoViewerItem else { return false }
        return url == object.url
    }
    
}
