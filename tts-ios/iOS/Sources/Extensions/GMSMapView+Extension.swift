//
//  GMSMapView+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import GoogleMaps

extension GMSMapView {

    var myLocationButton: UIButton? {
        guard let settingsView = subviews.first(where: { type(of: $0).description() == "GMSUISettingsPaddingView" })?.subviews.first else { return nil }
        return settingsView.subviews.first { type(of: $0).description() == "GMSx_QTMButton" } as? UIButton
    }
    
}
