//
//  AuthUserNameInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 28/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class AuthUserNameInteractor {
    
    private let user: UserInfoService
    private let form = AuthUserNameForm()
    private let disposeBag = DisposeBag()
    
    init(user: UserInfoService) {
        self.user = user
    }
    
    func setFirstName(_ value: String?) {
        form.firstName = value
    }
    
    func setLastName(_ value: String?) {
        form.lastName = value
    }
    
    func isFormValid() -> Bool {
        return form.errors.count == 0
    }

    func addUserName(completion: @escaping (Result<VoidResponse>) -> Void) {
        guard let firstName = form.firstName, let lastName = form.lastName else { return }
        user.addUserNameRequest(firstName: firstName, lastName: lastName)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
}
