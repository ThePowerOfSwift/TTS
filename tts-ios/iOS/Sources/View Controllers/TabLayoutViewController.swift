//
//  TabLayoutViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import XLPagerTabStrip

final class TabLayoutViewController: ButtonBarPagerTabStripViewController {
    
    var viewControllersForPagerTabStripController: [UIViewController]
    private let didChangeCurrentIndex: ((Int) -> Void)?
    
    init(viewControllersForPagerTabStripController: [UIViewController], didChangeCurrentIndex: ((Int) -> Void)?) {
        self.viewControllersForPagerTabStripController = viewControllersForPagerTabStripController
        self.didChangeCurrentIndex = didChangeCurrentIndex
        super.init(nibName: nil, bundle: nil)
        changeCurrentIndexProgressive = { [weak self] in
            self?.didChangeCurrentIndexProgressive(oldCell: $0, newCell: $1, progressPercentage: $2, changeCurrentIndex: $3, animated: $4)
        }
        
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = settings.style.buttonBarBackgroundColor
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 15)
        settings.style.buttonBarItemTitleColor = UIColor(r: 112, g: 124, b: 137)
        settings.style.selectedBarBackgroundColor = UIColor(r: 241, g: 52, b: 52)
        settings.style.buttonBarHeight = 40
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func loadView() {
        super.loadView()

        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = .flexibleDimensions
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        containerView = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(buttonBarView)
    }
    
    // MARK: - Data Source
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return viewControllersForPagerTabStripController
    }
    
    // MARK: - Current Index Handling

    private func didChangeCurrentIndexProgressive(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) {
        guard changeCurrentIndex else { return }
        newCell?.label.textColor = .white
        oldCell?.label.textColor = settings.style.buttonBarItemTitleColor
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        guard indexWasChanged else { return }
        
        didChangeCurrentIndex?(currentIndex)
    }
    
}
