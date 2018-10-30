//
//  AlamofireImage+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import AlamofireImage

extension AspectScaledToFillSizeWithRoundedCornersFilter: Sizable {
    
    public var size: CGSize {
        return (filters.first { $0 is Sizable } as! Sizable).size // swiftlint:disable:this force_cast
    }
    
}

extension AspectScaledToFillSizeCircleFilter: Sizable {
    
    public var size: CGSize {
        return (filters.first { $0 is Sizable } as! Sizable).size // swiftlint:disable:this force_cast
    }
    
}
