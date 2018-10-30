//
//  OrderTechServiceVariantsInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceVariantsInteractor {
    
    private let orders: OrderService
    private let auto: UserAuto
    private let serviceCenter: ServiceCenter
    private let selection: OrderTechServiceSelection
    private let disposeBag = DisposeBag()
    
    init(orders: OrderService, auto: UserAuto, serviceCenter: ServiceCenter, selection: OrderTechServiceSelection) {
        self.orders = orders
        self.auto = auto
        self.serviceCenter = serviceCenter
        self.selection = selection
    }
    
    func initialDate() -> Date {
        var date = Date()
        let time = DateToTimeTransformer().time(from: date)
        let calendar = Calendar.current
        if time.hour >= 18, let nextDate = calendar.date(byAdding: .day, value: 1, to: date).flatMap({ calendar.date(bySettingHour: 0, minute: 0, second: 0, of: $0) }) {
            date = nextDate
        }
        return date
    }
    
    func observeData(onNext: @escaping (OrderTechServiceVariantDTO) -> Void) {
        Observable.combineLatest(Observable.just(auto), Observable.just(serviceCenter), Observable.just(selection), variants.asObservable())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                onNext(OrderTechServiceVariantDTO(auto: $0.0, serviceCenter: $0.1, selection: $0.2, variants: $0.3))
            })
            .disposed(by: disposeBag)
    }
    
    var variants = Variable<[(OrderTechServiceGetVariantsResponse.Variant, Date)]?>(nil)
    
    func getVariants(date: Date, completion: @escaping (Result<Bool>) -> Void) {
        let shouldResetVariants: Bool
        if let firstDate = variants.value?.first?.1 {
            let isSameDay = Calendar.autoupdatingCurrent.compare(firstDate, to: date, toGranularity: .day) == .orderedSame
            shouldResetVariants = !isSameDay || date < firstDate
        } else {
            shouldResetVariants = false
        }
        
        orders.getVariants(autoUid: auto.id, serviceUid: serviceCenter.uid, kind: selection.kind, date: date)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                let pairs = response.variants.map { ($0, response.next) }
                if shouldResetVariants {
                    self?.variants.value = pairs
                } else {
                    self?.variants.value = (self?.variants.value ?? []) + pairs
                }
                completion(Result(value: shouldResetVariants))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: self.disposeBag)
    }
    
}
