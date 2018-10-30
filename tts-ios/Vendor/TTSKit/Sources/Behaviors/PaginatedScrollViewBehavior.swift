//
//  PaginatedScrollViewBehavior.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 01/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public final class PaginatedScrollViewBehavior: NSObject {
    
    public var observer: ((Int) -> Void)?
    
    private var _pageControl: UIPageControl
    public var pageControl: UIPageControl {
        get {
            return _pageControl
        }
        set {
            _pageControl.removeTarget(self, action: #selector(pageControlValueChanged(sender:)), for: .valueChanged)
            _pageControl = newValue
            bindPageControl()
        }
    }
    
    private var _scrollView: UIScrollView
    public var scrollView: UIScrollView {
        get {
            return _scrollView
        }
        set {
            contentOffsetObservation = nil
            contentSizeObservation = nil
            _scrollView = newValue
            bindScrollView()
        }
    }
    
    private var _currentPageIndex: Int = 0
    public var currentPageIndex: Int {
        get {
            return _currentPageIndex
        }
        set {
            setCurrentPageIndex(newValue, animated: false)
        }
    }
    
    public init(pageControl: UIPageControl, scrollView: UIScrollView) {
        _pageControl = pageControl
        _scrollView = scrollView
        super.init()
        bindPageControl()
        bindScrollView()
    }
    
    deinit {
        contentOffsetObservation = nil
        contentSizeObservation = nil
    }
    
    // MARK: - Scroll View
    
    private var contentOffsetObservation: NSKeyValueObservation?
    private var contentSizeObservation: NSKeyValueObservation?
    
    private func bindScrollView() {
        contentOffsetObservation = scrollView.observe(\.contentOffset) { [weak self] _, _ in
            self?.scrollViewDidScroll()
        }
        contentSizeObservation = scrollView.observe(\.contentSize) { [weak self] _, _ in
            self?.scrollViewDidChangeContentSize()
        }
    }
    
    private func scrollViewDidScroll() {
        let pageWidth = scrollView.bounds.width
        var page = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        page = max(0, page)
        page = min(pageControl.numberOfPages - 1, page)
        
        updateCurrentPageIndex(page)
    }
    
    private func scrollViewDidChangeContentSize() {
        let pageSize: CGFloat
        if scrollView.contentSize.width > scrollView.contentSize.height {
            // horizontal
            pageSize = round(scrollView.contentSize.width / scrollView.bounds.width)
        } else {
            // verical
            pageSize = round(scrollView.contentSize.height / scrollView.bounds.height)
        }
        pageControl.numberOfPages = Int(pageSize)
    }
    
    // MARK: - Pages Management
    
    public func setCurrentPageIndex(_ currentPageIndex: Int, animated: Bool) {
        let contentOffsetForCurrentPage = CGPoint(x: scrollView.bounds.width * CGFloat(currentPageIndex), y: 0)
        scrollView.setContentOffset(contentOffsetForCurrentPage, animated: animated)
    }
    
    private func updateCurrentPageIndex(_ currentPageIndex: Int) {
        guard currentPageIndex != _currentPageIndex else {
            return
        }
        _currentPageIndex = currentPageIndex
        
        pageControl.currentPage = currentPageIndex
        
        observer?(currentPageIndex)
    }
    
    // MARK: - Page Control
    
    private func bindPageControl() {
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc
    private func pageControlValueChanged(sender: UIPageControl) {
        setCurrentPageIndex(sender.currentPage, animated: IsAnimationAllowed())
    }
    
}
