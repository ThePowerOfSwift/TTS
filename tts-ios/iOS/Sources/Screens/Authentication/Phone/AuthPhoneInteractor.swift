//
//  AuthPhoneInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import TTSKit
import RxSwift

final class AuthPhoneInteractor {
    
    private let auth: AuthService
    private var form = AuthPhoneForm(phoneNumberPrefix: "+7")
    private let disposeBag = DisposeBag()

    init(auth: AuthService) {
        self.auth = auth
    }
    
    var phoneNumberPrefix: String? {
        return form.phoneNumberPrefix
    }
    
    func setPhoneNumber(_ value: String?) {
        form.phoneNumber = value
    }
    
    func isFormValid() -> Bool {
        return form.errors.count == 0
    }
    
    func callHotLine() {
        CallAction.call(phone: CallAction.hotLinePhoneNumber, completion: nil)
    }
    
    func getTempToken(completion: @escaping (Result<(PhoneNumber, GetTempTokenResponse)>) -> Void) {
        guard let string = form.phoneNumber, let phone = try? PhoneNumber(string) else { return }
        auth.getTempToken(phone: phone)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion(Result(value: (phone, $0)))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
}
