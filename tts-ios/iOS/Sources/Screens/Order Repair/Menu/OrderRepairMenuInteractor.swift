//
//  OrderRepairMenuInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 21/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderRepairMenuInteractor {
    
    private let repair: RepairService
    private let disposeBag = DisposeBag()
    
    init(repair: RepairService) {
        self.repair = repair
    }
    
    func sendData(ukrUid: String, comment: String?, completion: ((Result<MessageResponse>) -> Void)?) {
        repair.callUkr(ukrUid: ukrUid, comment: comment)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion?(Result(value: $0))
            }, onError: {
                completion?(Result(error: $0))
            })
            .disposed(by: disposeBag)
    }
    
}
