//
//  AuthCoordinator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 27/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class AuthCoordinator: Coordinator {
    
    private let auth: AuthService
    private let user: UserInfoService
    private let completion: () -> Void
    private let navigationController: UINavigationController
    
    init(auth: AuthService, user: UserInfoService, completion: @escaping () -> Void) {
        self.auth = auth
        self.user = user
        self.completion = completion
        navigationController = NavigationController(style: .barTintColor(UIColor(r: 19, g: 25, b: 43)), tintColor: .white, barStyle: .black)
    }
    
    func instantiateInitialViewController() -> UINavigationController {
        let interactor = AuthPhoneInteractor(auth: auth)
        let viewController = AuthPhoneViewController(interactor: interactor, completion: { [weak self] in
            self?.presentSmsConfirmViewController(phone: $0, response: $1)
        })
        
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
    private func presentSmsConfirmViewController(phone: PhoneNumber, response: GetTempTokenResponse) {
        let interactor = AuthSmsConfirmInteractor(auth: auth, user: user, phone: phone, response: response)
        let viewController = AuthSmsConfirmViewController(interactor: interactor, completion: { [weak self] _ in
            self?.completion()
        })
        navigationController.show(viewController, sender: nil)
    }
    
    private func presentUserNameViewController() {
        let interactor = AuthUserNameInteractor(user: user)
        let viewController = AuthUserNameViewController(interactor: interactor, completion: { [weak self] in
            self?.completion()
        })
        navigationController.show(viewController, sender: nil)
    }
    
}
