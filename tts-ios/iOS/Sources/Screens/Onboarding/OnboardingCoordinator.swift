//
//  OnboardingCoordinator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class OnboardingCoordinator: Coordinator {
    
    private let completion: () -> Void
    private let navigationController: UINavigationController
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        navigationController = NavigationController(style: .transparent, barStyle: .black)
    }
    
    func instantiateInitialViewController() -> UINavigationController {
        let viewController = OnboardingViewController { [weak self] in
            self?.completion()
        }
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
}
