//
//  HistoryTabsInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class HistoryTabsInteractor {
    
    private let treatment: TreatmentService
    private let treatmentDetail: TreatmentDetailService
    private let autos: UserAutoService
    private let disposeBag = DisposeBag()
    
    init(treatment: TreatmentService, treatmentDetail: TreatmentDetailService, autos: UserAutoService) {
        self.treatment = treatment
        self.treatmentDetail = treatmentDetail
        self.autos = autos
    }
    
    func observeAutos(onNext: @escaping ([UserAuto]) -> Void) {
        autos.observeAllSortedByOrder()
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func reloadData(completion: @escaping (Error?) -> Void) {
        autos.pull()
            .flatMap { [treatment] _ in treatment.pull() }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            })
            .disposed(by: disposeBag)
    }
    
    func createHistoryTreatmentsInteractor() -> HistoryTreatmentsInteractor {
        return HistoryTreatmentsInteractor(treatment: treatment, treatmentDetail: treatmentDetail)
    }
    
}
