//
//  OrderTechServiceVariantDTO.swift
//  tts
//
//  Created by Dmitry Nesterenko on 09/07/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

struct OrderTechServiceVariantDTO {
    
    let auto: UserAuto
    let serviceCenter: ServiceCenter
    let selection: OrderTechServiceSelection
    let variants: [(OrderTechServiceGetVariantsResponse.Variant, Date)]?
    
}
