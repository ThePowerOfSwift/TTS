//
//  HistoryDetailsInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift
import TTSKit

final class HistoryDetailsInteractor {
    
    private let treatmentDetail: TreatmentDetailService
    private let disposeBag = DisposeBag()
    
    init(treatmentDetail: TreatmentDetailService) {
        self.treatmentDetail = treatmentDetail
    }
    
    func observeTreatmentDetail(treatmentId: String, onNext: @escaping (GetTreatmentDetailResponse?) -> Void) {
        treatmentDetail.observe(treatmentId: treatmentId)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func reloadData(treatmentId: String, completion: @escaping (Result<GetTreatmentDetailResponse?>) -> Void) {
        treatmentDetail.pull(treatmentId: treatmentId)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            })
            .disposed(by: disposeBag)
    }
    
}
