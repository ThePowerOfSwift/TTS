//
//  ServiceCenterIconView.swift
//  tts
//
//  Created by Dmitry Nesterenko on 27/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import AlamofireImage
import TTSKit

final class ServiceCenterIconView: UIView {
    
    private let imageView = UIImageView()
    private let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "marker"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundImageView)
        addSubview(imageView)
        sizeToFit()
        
        let imageViewDimension: CGFloat = 24
        let x = round(bounds.midX - imageViewDimension / 2)
        imageView.frame = CGRect(x: x, y: 6, width: imageViewDimension, height: imageViewDimension)
        imageView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Resizing Behaviour
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return backgroundImageView.bounds.size
    }
    
    // MARK: - Configuring Image
    
    fileprivate func setImage(url: URL, completion: (() -> Void)?) {
        imageView.image = nil
        imageView.af_setImage(withURL: url, filter: AspectScaledToFitSizeFilter(size: imageView.bounds.size), completion: { _ in
            completion?()
        })
    }
    
    fileprivate func setImage(number: Int, completion: (() -> Void)?) {
        imageView.image = ClusterIconGenerator().icon(forSize: number, fillColor: nil, applyMinRectDimension: false)
        completion?()
    }
    
}

extension ServiceCenterIconView {
    
    /// - param:
    ///   - completion called when image was loaded asyncronously
    convenience init(group: ServiceCenterGroup, completion: (() -> Void)?) {
        self.init()

        // Для данного сц, если к нему не привязан авто, необходимо отображать иконку ттс.
        // Если привязано 1 авто, то отображать иконку его бренда
        // Если привязано 2, то отображать цифру 2
        // see https://redmine.e-legion.com/issues/111659
        let autos = group.services.reduce(into: [(ServiceCenter, UserAutoLight)]()) { result, service in
            let pairs = service.auto?.map {(service, $0)}
            result.append(contentsOf: pairs ?? [])
        }
        if autos.count == 0 {
            imageView.image = #imageLiteral(resourceName: "tts_marker_image")
            completion?()
        } else if autos.count == 1 {
            if let url = autos[0].0.brandImage {
                setImage(url: url, completion: completion)
            } else {
                imageView.image = #imageLiteral(resourceName: "tts_marker_image")
                completion?()
            }
        } else {
            setImage(number: autos.count, completion: completion)
        }
    }
    
}
