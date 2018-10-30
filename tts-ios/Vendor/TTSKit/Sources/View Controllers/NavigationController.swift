//
//  NavigationController.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

open class NavigationController: UINavigationController {

    public init(style: NavigationBar.Style, tintColor: UIColor? = nil, barStyle: UIBarStyle = .default) {
        super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        let navigationBar = self.navigationBar as! NavigationBar // swiftlint:disable:this force_cast
        navigationBar.shouldCleanTitleForBackBarButtonItem = true
        if let tintColor = tintColor {
            navigationBar.tintColor = tintColor
        }
        navigationBar.barStyle = barStyle
        navigationBar.style = style
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // hiding search bar clipping background
        guard let navigationBar = navigationBar as? NavigationBar, navigationBar.shouldCleanTitleForBackBarButtonItem else { return }
        guard let paletteClippingView = view.subviews.first(where: { String(describing: type(of: $0)).contains("PaletteClipping") }) else { return }
        guard let searchPalette = paletteClippingView.subviews.first else { return }
        guard let barBackground = searchPalette.subviews.first(where: { String(describing: type(of: $0)).contains("BarBackground") }) else { return }
        guard let imageView = barBackground.subviews.first(where: { $0 is UIImageView }) else { return }
        imageView.isHidden = true
    }
    
}
