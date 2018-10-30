//
//  UIViewController+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func clearSelectionWhenInteractionEnds(for container: IndexPathsSelectionContainer, animated: Bool) {
        guard let indexPaths = container.selectedIndexPaths else {
            return
        }
        
        container.deselectAll(animated: animated)
        
        transitionCoordinator?.notifyWhenInteractionChanges { context in
            if context.isCancelled {
                indexPaths.forEach({ container.select(indexPath: $0, animated: animated) })
            }
        }
    }
        
}
