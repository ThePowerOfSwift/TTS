//
//  GarageAutoInfoInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class GarageAutoInfoInteractor {
    
    private let auto: UserAuto
    private let autos: UserAutoService
    private let services: ServiceCentersService
    private let archive: ArchivedAutoService
    private let disposeBag = DisposeBag()
    private var observeDataDisposable: Disposable?
    
    deinit {
        observeDataDisposable?.dispose()
    }
    
    init(auto: UserAuto, autos: UserAutoService, services: ServiceCentersService, archive: ArchivedAutoService) {
        self.auto = auto
        self.autos = autos
        self.services = services
        self.archive = archive
    }
    
    func observeData(onNext: @escaping (UserAuto?) -> Void) {
        observeDataDisposable = autos.observe(id: auto.id)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
    }
    
    func stopObservingData() {
        observeDataDisposable?.dispose()
    }
    
    func archive(onArchive: @escaping () -> Void, onError: @escaping (Error) -> Void, onCompleted: @escaping () -> Void) {
        // do not add this to dispose bag to allow new data to be pulled even after the interactor was deallocated
        // see https://redmine.e-legion.com/issues/114809
        _ = archive.moveToArchive(vin: auto.vin)
            .observeOn(MainScheduler.instance)
            .do(onError: onError, onCompleted: onArchive)
            .andThen(Single.zip(autos.pull(), services.pull()))
            .catchError { _ in Single.just(([], [])) }
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { _ in
                onCompleted()
            })
            .subscribe()
    }
    
}
