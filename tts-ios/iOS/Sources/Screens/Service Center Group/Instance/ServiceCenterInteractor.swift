//
//  ServiceCenterInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 19/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class ServiceCenterInteractor {
    
    private let serviceId: Int
    private let services: ServiceCentersService
    private let disposeBag = DisposeBag()
    
    init(serviceId: Int, services: ServiceCentersService) {
        self.serviceId = serviceId
        self.services = services
    }
    
    func observeData(onNext: @escaping (ServiceCenter?) -> Void) {
        services.observe(serviceId: serviceId)
            .distinctUntilChanged()
            .map { [serviceId] in $0?.services.first(where: { $0.id == serviceId }) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
}
