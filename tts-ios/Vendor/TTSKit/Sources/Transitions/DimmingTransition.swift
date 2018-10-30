//
//  DimmingTransition.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

public final class DimmingTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
