//
//  ServiceCentersFilterable.swift
//  tts
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

protocol ServiceCentersFilterable {
    
    func applyFilter(brand: CarBrand?, city: NamedValue?)
    
}
