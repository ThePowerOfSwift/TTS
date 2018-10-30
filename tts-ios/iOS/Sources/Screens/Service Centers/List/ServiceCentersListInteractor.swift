//
//  ServiceCentersListInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 13/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class ServiceCentersListInteractor {
    
    private let services: ServiceCentersService
    private let autos: UserAutoService
    private let location: Observable<CLLocation?>
    private let disposeBag = DisposeBag()
    
    deinit {
        dataObserver?.dispose()
    }
    
    init(services: ServiceCentersService, autos: UserAutoService, location: Observable<CLLocation?>) {
        self.services = services
        self.autos = autos
        self.location = location
    }
    
    private var dataObserver: Disposable?
    
    func observeData(brand: CarBrand?, city: NamedValue?, onNext: @escaping (([ServiceCenterGroup], CLLocation?)) -> Void) {
        let groups = services.observeAllSortedByOrder()
            .map { $0.filter(brand: brand, city: city) }
            .distinctUntilChanged()
        
        dataObserver?.dispose()
        dataObserver = Observable.combineLatest(groups, location)
            .map {
                if let location = $0.1 {
                    let groups = $0.0.sorted { location.distance(from: CLLocation(coordinate: $0.coordinate)) < location.distance(from: CLLocation(coordinate: $1.coordinate)) }
                    return (groups, location)
                } else {
                    return $0
                }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
    }
    
    func createServiceCenterGroupTabsInteractor(serviceId: Int) -> ServiceCenterGroupTabsInteractor {
        return ServiceCenterGroupTabsInteractor(services: services, autos: autos, filter: .serviceId(serviceId))
    }
    
    func createServiceCenterGroupTabsInteractor(latitude: String, longitude: String) -> ServiceCenterGroupTabsInteractor {
        return ServiceCenterGroupTabsInteractor(services: services, autos: autos, filter: .location(latitude: latitude, longitude: longitude))
    }
    
}
