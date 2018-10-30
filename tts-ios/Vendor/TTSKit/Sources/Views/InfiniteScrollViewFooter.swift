//
//  InfiniteScrollViewFooter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit
import RxSwift

public final class InfiniteScrollViewFooter: UIView {

    private var observation: Disposable?
    
    deinit {
        observation?.dispose()
    }
    
    // MARK: - Observing View-Related Changes
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        observation?.dispose()
        
        guard let scrollView = newSuperview as? UIScrollView else { return }
        
        observation = KVOObservable<CGSize>(target: scrollView, keyPath: "contentSize").subscribe(onNext: { [weak self] _ in
            self?.setNeedsLayout()
        })
        
        setNeedsLayout()
    }
    
    // MARK: - Laying out Subviews
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let scrollView = superview as? UIScrollView else { return }
        frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.contentSize.width, height: scrollView.bounds.height)
    }

}
