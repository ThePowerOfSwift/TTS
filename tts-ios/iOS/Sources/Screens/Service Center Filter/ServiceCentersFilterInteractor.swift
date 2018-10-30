//
//  ServiceCentersFilterInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class ServiceCentersFilterInteractor {
    
    private let dictionaries: DictionariesService
    
    init(dictionaries: DictionariesService) {
        self.dictionaries = dictionaries
    }
    
    func createCitiesInteractor() -> GenericListInteractor<NamedValue> {
        return GenericListInteractor { [dictionaries] in dictionaries.getCities() }
    }
    
    func createBrandListInteractor() -> BrandListInteractor {
        return BrandListInteractor(dictionaries: dictionaries)
    }
    
}
