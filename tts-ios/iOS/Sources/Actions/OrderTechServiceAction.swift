//
//  OrderTechServiceAction.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class OrderTechServiceAction {
    
    enum Error: LocalizedError {

        case notUploadedTo1c

        var errorDescription: String? {
            switch self {
            case .notUploadedTo1c:
                return "Автомобиль находится на этапе модерации, запись в сервисный центр недоступна"
            }
        }

    }
    
    private let orders: OrderService
    private let autos: UserAutoService
    
    init(orders: OrderService, autos: UserAutoService) {
        self.orders = orders
        self.autos = autos
    }
    
    func run(presentingViewController: (UIViewController & ErrorPresenting), auto: UserAuto, service: ServiceCenter, completion: (() -> Void)?) {
        if auto.upload1c {
            let interactor = OrderTechServiceInteractor(orders: orders, autos: autos, auto: auto, serviceCenter: service)
            let viewController = OrderTechServiceNavigationController(interactor: interactor, close: {
                $0.dismiss(animated: IsAnimationAllowed(), completion: nil)
            })
            presentingViewController.present(viewController, animated: IsAnimationAllowed(), completion: nil)
        } else {
            presentingViewController.showError(Error.notUploadedTo1c, animated: IsAnimationAllowed(), close: {
                completion?()
            })
        }
    }
    
}
