//
//  OnboardingPageView.swift
//  tts
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class OnboardingPageView: UIView, NibLoadable {

    @IBOutlet var topLayoutGuide: NSLayoutConstraint!
    @IBOutlet var bottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    
}
