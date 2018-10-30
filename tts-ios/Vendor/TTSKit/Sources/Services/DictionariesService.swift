//
//  DictionariesService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift

public final class DictionariesService {
    
    private let client: URLRequestManaging
    
    public init(client: URLRequestManaging) {
        self.client = client
    }
    
    public func getBrands() -> Single<[CarBrand]> {
        return client.execute(GetBrandsRequest()).map {$0.value.brands}
    }
    
    public func getModels(brandId: Int) -> Single<[NamedValue]> {
        return client.execute(GetModelsByBrandRequest(brandId: brandId)).map {$0.value.models}
    }
    
    public func getEquipments(brandId: Int, modelId: Int, year: Int) -> Single<[CarEquipment]> {
        return client.execute(GetEquipmentsRequest(brandId: brandId, modelId: modelId, year: year)).map {$0.value.equipments}
    }
    
    public func getCities() -> Single<[NamedValue]> {
        return client.execute(GetCitiesRequest()).map {$0.value.cities}
    }
    
    public func getServiceCenterByCity(cityId: Int) -> Single<[ServiceCenter]> {
        return client.execute(GetServiceCenterByCityRequest(cityId: cityId)).map {$0.value.services}
    }
    
    public func getServiceCenterByCityBrand(cityId: Int, brandId: Int) -> Single<[ServiceCenter]> {
        return client.execute(GetServiceCenterByCityBrandRequest(cityId: cityId, brandId: brandId)).map {$0.value.services}
    }
    
    public func getServiceCenterGroup() -> Single<[ServiceCenterGroup]> {
        return client.execute(GetServiceCenterGroupRequest()).map {$0.value.services}
    }
    
}
