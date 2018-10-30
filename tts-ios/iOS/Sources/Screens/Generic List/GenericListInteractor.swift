//
//  GenericListInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class GenericListInteractor<T> {
    
    private let disposeBag = DisposeBag()
    private let request: () -> Single<[T]>
    
    init(request: @escaping () -> Single<[T]>) {
        self.request = request
    }
    
    func loadData(completion: @escaping (Result<[T]>) -> Void) {
        request()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
}
