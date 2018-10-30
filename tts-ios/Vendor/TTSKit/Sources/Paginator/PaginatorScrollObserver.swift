//
//  PaginatorScrollObserver.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import RxSwift

public class PaginatorScrollObserver<Service: PaginatorService> : NSObject, UIScrollViewDelegate {
    
    var threshold: CGFloat
    
    public let paginator: Paginator<Service>
    
    private let disposables = DisposeBag()
    
    public init(paginator: Paginator<Service>, threshold: CGFloat) {
        self.paginator = paginator
        self.threshold = threshold
    }
    
    private var loadingPage: Int = 0
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let frameHeight = scrollView.frame.height
        
        let thresholdTriggered = contentHeight - (offsetY + frameHeight) < threshold
        let nextPage = paginator.page.next()
        if nextPage != loadingPage, thresholdTriggered {
            loadingPage = nextPage
            paginator.next().subscribe().disposed(by: disposables)
        }
    }
    
}
