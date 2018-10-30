//
//  BrandListInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class BrandListInteractor {
    
    private let dictionaries: DictionariesService
    private let disposeBag = DisposeBag()
    
    init(dictionaries: DictionariesService) {
        self.dictionaries = dictionaries
    }
    
    func loadData(completion: @escaping (Result<[CarBrand]>) -> Void) {
        dictionaries.getBrands()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
    func createModelsInteractor(brandId: Int) -> GenericListInteractor<NamedValue> {
        return GenericListInteractor { [dictionaries] in dictionaries.getModels(brandId: brandId) }
    }
    
}
