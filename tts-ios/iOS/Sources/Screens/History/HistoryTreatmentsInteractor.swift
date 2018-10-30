//
//  HistoryTreatmentsInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class HistoryTreatmentsInteractor {
    
    private let treatment: TreatmentService
    private let treatmentDetail: TreatmentDetailService
    private let disposeBag = DisposeBag()
    
    init(treatment: TreatmentService, treatmentDetail: TreatmentDetailService) {
        self.treatment = treatment
        self.treatmentDetail = treatmentDetail
    }
    
    func observeTreatments(autoId: String, onNext: @escaping ([Treatment]) -> Void) {
        treatment.observeAllSortedByOrder(autoId: autoId, ascending: false)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func createHistoryDetailsInteractor() -> HistoryDetailsInteractor {
        return HistoryDetailsInteractor(treatmentDetail: treatmentDetail)
    }
    
}
