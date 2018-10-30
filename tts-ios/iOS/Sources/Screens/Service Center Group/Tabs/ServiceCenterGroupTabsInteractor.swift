//
//  ServiceCenterGroupTabsInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 19/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import CoreLocation
import RxSwift
import AlamofireImage

final class ServiceCenterGroupTabsInteractor {
    
    enum Filter {
        case location(latitude: String, longitude: String)
        case serviceId(Int)
    }
    
    private let services: ServiceCentersService
    private let autos: UserAutoService
    private let filter: Filter
    private let disposeBag = DisposeBag()
    
    init(services: ServiceCentersService, autos: UserAutoService, filter: Filter) {
        self.services = services
        self.autos = autos
        self.filter = filter
    }
    
    func observeData(onNext: @escaping ((ServiceCenterGroup, [URL: UIImage])?) -> Void) {
        let observable: Observable<ServiceCenterGroup?>
        switch filter {
        case .location(let latitude, let longitude):
            observable = services.observe(latitude: latitude, longitude: longitude)
        case .serviceId(let serviceId):
            observable = services.observe(serviceId: serviceId)
        }
        
        observable
            // ignore onNext events for bound/unbound cars. the will be handled by ServiceCenterInteractor
            .distinctUntilChanged { $0?.coordinate == $1?.coordinate && $0?.services.map {$0.id} == $1?.services.map {$0.id} }
            .flatMap { group -> Single<(ServiceCenterGroup, [URL: UIImage])?> in
                if let group = group {
                    let urls = group.services.compactMap {$0.brandImage}
                    return Single.zip(Single.just(group), ImageDownloader.default.download(urls: urls)).map {Optional($0)}
                } else {
                    return Single.just(nil)
                }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func reloadData(completion: ((Result<[UserAuto]>) -> Void)?) {
        // pulling user autos for bind action at service center screen
        autos.pull()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion?(Result(value: $0))
            }, onError: {
                completion?(Result(error: $0))
            })
            .disposed(by: disposeBag)
    }
    
    func createServiceCenterInteractor(serviceId: Int) -> ServiceCenterInteractor {
        return ServiceCenterInteractor(serviceId: serviceId, services: services)
    }
    
    func createBindAction(brandId: Int) -> BindServiceCenterAction {
        return BindServiceCenterAction(interactor: BindServiceCenterInteractor(brandId: brandId, autos: autos, services: services))
    }
    
}
