//
//  CLLocation+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/04/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import CoreLocation

extension CLLocation {
    
    public convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
}
