//
//  HistoryEmptyViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import TTSKit

final class HistoryEmptyViewController: UIViewController, IndicatorInfoProvider {

    private let auto: UserAuto?
    
    init(auto: UserAuto?) {
        self.auto = auto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Providing Indicator Info
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: auto?.brand)
    }
    
}
