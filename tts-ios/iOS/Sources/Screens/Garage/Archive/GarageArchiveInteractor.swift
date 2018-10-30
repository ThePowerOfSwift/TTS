//
//  GarageArchiveInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 12/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class GarageArchiveInteractor {
    
    private let archive: ArchivedAutoService
    private let autos: UserAutoService
    private let services: ServiceCentersService
    private let disposeBag = DisposeBag()
    
    init(autos: UserAutoService, services: ServiceCentersService, archive: ArchivedAutoService) {
        self.autos = autos
        self.services = services
        self.archive = archive
    }
    
    func observeData(onNext: @escaping ([UserAuto]) -> Void) {
        archive.observeAllSortedByOrder()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func reloadData(completion: @escaping (Error?) -> Void) {
        archive.pull()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            }).disposed(by: disposeBag)
    }
    
    func removeFromArchive(vin: String, completion: @escaping (Error?) -> Void) {
        archive.removeFromArchive(vin: vin)
            .andThen(autos.pull())
            .flatMap { _ in self.services.pull() }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            })
            .disposed(by: disposeBag)
    }
    
}
