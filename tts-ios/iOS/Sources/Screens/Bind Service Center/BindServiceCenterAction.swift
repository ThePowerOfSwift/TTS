//
//  BindServiceCenterAction.swift
//  tts
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class BindServiceCenterAction {
    
    enum Result {
        case succeeded
        case cancelled
        case noUserAutos
        
        /// Error message was presented by the presenting view controller
        case error(underlying: Swift.Error)
    }
    
    private let interactor: BindServiceCenterInteractor
    
    init(interactor: BindServiceCenterInteractor) {
        self.interactor = interactor
    }
    
    func run(presentingViewController: (UIViewController & ErrorPresenting), uid: String, completion: ((Result) -> Void)? = nil) {
        let autos = interactor.fetchData()
        
        if autos.count == 0 {
            completion?(Result.noUserAutos)
        } else if autos.count == 1 {
            let auto = autos[0]
            
            if autos[0].serviceCenter == nil {
                // Производится вызов API метода bindingServiceCenter. По результатам работы API-метода отображается всплывающее сообщение.
                sendBindUserAutoRequest(presentingViewController: presentingViewController, uid: uid, vin: auto.vin, completion: completion)
            } else {
                // Необходимо отобразить модальное окно с просьбой подтвердить привязку авто к другому СЦ.
                // При положительном решении пользователя производятся действия как в предыдущем сценарии.
                BindServiceCenterViewController.presentPromptViewController(presentingViewController: presentingViewController, proceed: { [weak self] in
                    self?.sendBindUserAutoRequest(presentingViewController: presentingViewController, uid: uid, vin: auto.vin, completion: completion)
                }, cancel: {
                    completion?(Result.cancelled)
                })
            }
        } else {
            // показать выбор сервисного центра
            let viewController = BindServiceCenterViewController(uid: uid, interactor: interactor, complete: {
                presentingViewController.dismiss(animated: IsAnimationAllowed(), completion: {
                    completion?(Result.succeeded)
                })
            }, cancel: {
                presentingViewController.dismiss(animated: IsAnimationAllowed(), completion: {
                    completion?(Result.cancelled)
                })
            })
            
            let navigationController = NavigationController(style: .barTintColor(UIColor(r: 19, g: 25, b: 43)), tintColor: .white, barStyle: .black)
            navigationController.viewControllers = [viewController]
            
            presentingViewController.present(navigationController, animated: IsAnimationAllowed())
        }
    }

    private func sendBindUserAutoRequest(presentingViewController: (UIViewController & ErrorPresenting), uid: String, vin: String, completion: ((Result) -> Void)?) {
        interactor.bindingServiceCenter(uid: uid, vin: vin) {
            if let error = $0 {
                presentingViewController.showError(error, close: {
                    completion?(Result.error(underlying: error))
                })
            } else {
                completion?(Result.succeeded)
            }
        }
    }
    
}
