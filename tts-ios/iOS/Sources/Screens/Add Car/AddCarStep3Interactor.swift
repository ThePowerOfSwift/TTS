//
//  AddCarStep3Interactor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class AddCarStep3Interactor {
    
    private let autos: UserAutoService
    private let services: ServiceCentersService
    private let disposeBag = DisposeBag()
    
    init(autos: UserAutoService, services: ServiceCentersService) {
        self.autos = autos
        self.services = services
    }
    
    func addUserAuto(brandId: Int, modelId: Int, complectationId: Int?, year: Int, gosnomer: String, vin: String, mileage: Int?, serviceId: String?, completion: @escaping (Error?) -> Void) {
        autos.addUserAuto(brandId: brandId, modelId: modelId, complectationId: complectationId, year: year, gosnomer: gosnomer, vin: vin, mileage: mileage, serviceId: serviceId)
            .flatMap { _ in self.autos.pull() }
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            })
            .flatMap { _ in self.services.pull() }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
