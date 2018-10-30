//
//  SubmitButton.swift
//  tts
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

@objc
class SubmitButton: UIButton {
    
    private let spinner = UIActivityIndicatorView(style: .white)
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        spinner.hidesWhenStopped = true
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.trailingAnchor.constraint(equalTo: spinner.leadingAnchor, constant: -12).isActive = true
        titleLabel?.centerYAnchor.constraint(equalTo: spinner.centerYAnchor).isActive = true
    }
    
    // MARK: - Animating
    
    func startAnimating() {
        spinner.startAnimating()
    }
    
    func stopAnimating() {
        spinner.stopAnimating()
    }
    
}
