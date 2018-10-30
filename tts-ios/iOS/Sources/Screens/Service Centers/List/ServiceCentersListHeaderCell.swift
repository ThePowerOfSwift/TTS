//
//  ServiceCentersListHeaderCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 17/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

final class ServiceCentersListHeaderCell: UICollectionViewCell, NibLoadable {
    
    @IBOutlet private var textLabel: UILabel!
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
}
