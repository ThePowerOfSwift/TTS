//
//  AboutHeaderCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class AboutHeaderCell: UICollectionViewCell, NibLoadable {
    
    @IBOutlet private var bundleVersionLabel: UILabel!
    
    var item: AboutHeaderItem? {
        didSet {
            if let item = item {
                bundleVersionLabel.text = "Версия " + BundleVersionFormatter().string(from: item.bundleVersion)
            } else {
                bundleVersionLabel.text = nil
            }
        }
    }
    
}
