//
//  OrderTechServiceAppointmentDTO.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

struct OrderTechServiceAppointmentDTO {
    
    let userAuto: UserAuto
    let serviceCenter: ServiceCenter
    let description: String
    let price: TechServicePrice
    let period: Range<Date>
    
}
