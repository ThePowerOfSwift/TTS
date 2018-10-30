//
//  AuthSmsConfirmInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 27/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class AuthSmsConfirmInteractor {
    
    let auth: AuthService
    let user: UserInfoService
    let phone: PhoneNumber
    private var response: GetTempTokenResponse
    private let disposeBag = DisposeBag()
    
    init(auth: AuthService, user: UserInfoService, phone: PhoneNumber, response: GetTempTokenResponse) {
        self.auth = auth
        self.user = user
        self.phone = phone
        self.response = response
    }
    
    func getAccessToken(smsCode: String, completion: @escaping (Result<GetAccessTokenResponse>) -> Void) {
        auth.getAccessToken(phone: phone, tempToken: response.temp_token, smsCode: smsCode)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
    func getTempToken(completion: @escaping (Result<GetTempTokenResponse>) -> Void) {
        auth.getTempToken(phone: phone)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.response = $0
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
    private var countdownTimer: DispatchSourceTimer?
    
    func scheduleTimeoutCountdown(timeInterval: TimeInterval, tick: @escaping (TimeInterval) -> Void, completion: @escaping () -> Void) {
        let startDate = Date()
        countdownTimer?.cancel()
        countdownTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        countdownTimer?.schedule(deadline: .now(), repeating: .milliseconds(200))
        countdownTimer?.setEventHandler { [weak self] in
            let timeIntervalSinceStart = Date().timeIntervalSince(startDate)
            if timeIntervalSinceStart >= timeInterval - 1 {
                completion()
                self?.countdownTimer?.cancel()
                self?.countdownTimer = nil
            } else {
                tick(timeIntervalSinceStart)
            }
        }
        countdownTimer?.resume()
    }
    
}
