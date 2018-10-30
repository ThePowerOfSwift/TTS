//
//  BindServiceCenterInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift
import TTSKit

final class BindServiceCenterInteractor {
    
    private let brandId: Int
    private let autos: UserAutoService
    private let services: ServiceCentersService
    private let disposeBag = DisposeBag()
    
    init(brandId: Int, autos: UserAutoService, services: ServiceCentersService) {
        self.brandId = brandId
        self.autos = autos
        self.services = services
    }
    
    func observeData(onNext: @escaping ([UserAuto]) -> Void) {
        autos.observeAllSortedByOrder()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func fetchData() -> [UserAuto] {
        return self.autos.fetchAll(brandId: brandId)
    }
    
    func reloadData(completion: @escaping (Error?) -> Void) {
        autos.pull()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            }).disposed(by: disposeBag)
    }
    
    func bindingServiceCenter(uid: String, vin: String, completion: @escaping (Error?) -> Void) {
        autos.bindingServiceCenter(uid: uid, vin: vin)
            .flatMap { _ in Single.zip(self.autos.pull(), self.services.pull()) }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            }).disposed(by: disposeBag)
    }
    
}
