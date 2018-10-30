//
//  ErrorPresenting.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol PresentableError: LocalizedError {
    var canBePresented: Bool { get }
}

extension PresentableError {
    var canBePresented: Bool {
        return true
    }
}

public protocol ErrorPresenting {
    
    func showError(title: String, message: String?, animated: Bool, close: (() -> Void)?, completion: (() -> Void)?)
    
}

extension ErrorPresenting {
    
    public func showError(_ error: Error, animated: Bool = false, close: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let canBePresented = (error as? PresentableError)?.canBePresented ?? true
        guard canBePresented else { return }
        
        var message: String?
        #if DEBUG
            message = String(describing: error)
        #else
            if let localizedError = error as? LocalizedError {
                message = localizedError.failureReason
            }
        #endif
        
        showError(title: error.localizedDescription, message: message, animated: animated, close: close, completion: completion)
    }
    
    public func showError(title: String, message: String?, animated: Bool) {
        showError(title: title, message: message, animated: animated, close: nil, completion: nil)
    }
    
}

extension ErrorPresenting where Self: UIViewController {
    
    public func showError(title: String, message: String?, animated: Bool, close: (() -> Void)?, completion: (() -> Void)?) {
        // skip view controller presentation if view controller is not in the view hierarchy to avoid memory leak
        guard viewIfLoaded?.window != nil else { return }
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        
        let viewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in
            close?()
        }))
        present(viewController, animated: animated, completion: completion)
    }
    
}
