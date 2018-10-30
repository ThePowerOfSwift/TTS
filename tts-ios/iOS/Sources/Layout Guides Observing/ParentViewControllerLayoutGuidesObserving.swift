//
//  ParentViewControllerLayoutGuidesObserving.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

protocol ParentViewControllerLayoutGuidesObserving {
    
    func parentViewControllerDidLayoutSubviews(topLayoutGuideLength: CGFloat, bottomLayoutGuideLength: CGFloat)
    
}
