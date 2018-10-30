//
//  ProfileUserInfoCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 30/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class ProfileUserInfoCell: UICollectionViewCell, NibLoadable {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var bonusLabel: UILabel!
    @IBOutlet private var phoneLabel: UILabel!
    @IBOutlet private var imageViewTopSpace: NSLayoutConstraint!
    @IBOutlet var bonusButton: UIButton!
    
    var item: ProfileUserInfoItem? {
        didSet {
            nameLabel.text = item?.name
            bonusLabel.attributedText = "\(item?.bonuses ?? 0)"
                .with(StringAttributes {
                    $0.font = .systemFont(ofSize: 32, weight: .bold)
                    $0.foregroundColor = .white
                    $0.alignment = .center
                })
                .appending("\n")
                .appending("бонусов".with(StringAttributes {
                    $0.font = .systemFont(ofSize: 13)
                    $0.foregroundColor = .white
                    $0.alignment = .center
                }))
            
            if let phone = item?.phone {
                phoneLabel.text = PhoneNumberFormatter().string(from: phone)
            } else {
                phoneLabel.text = nil
            }
        }
    }
    
    var imageViewTopSpaceOffset: CGFloat = 0 {
        didSet {
            imageViewTopSpace.constant = imageViewTopSpaceOffset - 20
        }
    }
    
}
