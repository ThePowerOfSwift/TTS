//
//  OrderRepairInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 21/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class OrderRepairInteractor {
    
    private let auto: UserAuto
    private let repair: RepairService
    
    init(auto: UserAuto, repair: RepairService) {
        self.auto = auto
        self.repair = repair
    }
    
    func createCitiesInteractor() -> GenericListInteractor<NamedValue> {
        return GenericListInteractor { [repair] in repair.getUkr().map { $0.cities } }
    }
    
    func createRepairPointsInteractor(cityId: Int) -> GenericListInteractor<RepairPoint> {
        return GenericListInteractor { [repair] in repair.getUkrByCity(cityId: cityId).map { $0.response } }
    }
    
    func createOrderRepairMenuInteractor() -> OrderRepairMenuInteractor {
        return OrderRepairMenuInteractor(repair: repair)
    }
    
}
