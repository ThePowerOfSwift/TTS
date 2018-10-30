//
//  AddCarInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class AddCarInteractor {
    
    private let autos: UserAutoService
    private let services: ServiceCentersService
    private let dictionaries: DictionariesService
    private let disposeBag = DisposeBag()
    
    init(autos: UserAutoService, services: ServiceCentersService, dictionaries: DictionariesService) {
        self.autos = autos
        self.services = services
        self.dictionaries = dictionaries
    }
    
    func createBrandListInteractor() -> BrandListInteractor {
        return BrandListInteractor(dictionaries: dictionaries)
    }
    
    func createYearInteractor() -> GenericListInteractor<Int> {
        return GenericListInteractor { Single.just(Array(1892..<Calendar(identifier: .gregorian).component(.year, from: Date()) + 1)) }
    }
    
    func createEquipmentsInteractor(brandId: Int, modelId: Int, year: Int) -> GenericListInteractor<CarEquipment> {
        return GenericListInteractor { [dictionaries] in dictionaries.getEquipments(brandId: brandId, modelId: modelId, year: year) }
    }
    
    func createCitiesInteractor() -> GenericListInteractor<NamedValue> {
        return GenericListInteractor { [dictionaries] in dictionaries.getCities() }
    }
    
    func createServiceCenterInteractor(cityId: Int, brandId: Int) -> GenericListInteractor<ServiceCenter> {
        return GenericListInteractor { [dictionaries] in dictionaries.getServiceCenterByCityBrand(cityId: cityId, brandId: brandId) }
    }
    
    func createAddCarStep3Interactor() -> AddCarStep3Interactor {
        return AddCarStep3Interactor(autos: autos, services: services)
    }
    
}
