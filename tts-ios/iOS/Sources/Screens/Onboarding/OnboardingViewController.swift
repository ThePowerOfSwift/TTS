//
//  OnboardingViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class OnboardingViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet private var glowImageViewTopSpace: NSLayoutConstraint!
    @IBOutlet private var glowImageView: UIImageView!
    @IBOutlet private var glowCenterX: NSLayoutConstraint!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var submitButton: SubmitButton!

    private var paginating: PaginatedScrollViewBehavior!
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Navigation Interface
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Пропустить", style: .plain) { [weak self] in
                self?.completion()
            }
            navigationItem.rightBarButtonItem?.tintColor = .white
        }
        return navigationItem
    }
    
    // MARK: - Managing the View
    
    private var pageViews = [OnboardingPageView]()
    private var pageViewTopSpaceConstant: CGFloat = 0
    private var pageViewBottomSpaceConstant: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        paginating = PaginatedScrollViewBehavior(pageControl: pageControl, scrollView: scrollView)
        
        let pages = [(#imageLiteral(resourceName: "intro_1"), "Записывайтесь\nна обслуживание"), (#imageLiteral(resourceName: "intro_2"), "Оценивайте\nкачество"), (#imageLiteral(resourceName: "intro_3"), "Изучайте\nдетализацию")]
        _ = zip(0..<pages.count, pages).reduce([OnboardingPageView](), {
            let (index, page) = $1
            
            let view = OnboardingPageView.loadFromNib()!
            view.translatesAutoresizingMaskIntoConstraints = false
            view.frame = scrollView.bounds
            view.imageView.image = page.0
            view.textLabel.text = page.1
            scrollView.addSubview(view)
            pageViewTopSpaceConstant = view.topLayoutGuide.constant
            pageViewBottomSpaceConstant = view.bottomLayoutGuide.constant
            pageViews.append(view)

            // pin to top and bottom superview edges
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            
            // pin width and height
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            
            // pin leading edge
            if index == 0 {
                // first page
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            } else {
                // middle page
                $0.last!.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            }
            
            // pin trailing edge
            if index == pages.count - 1 {
                // last page
                view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
            }

            return $0 + [view]
        })
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGlowImagePosition()
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            pageViews.forEach {
                $0.topLayoutGuide.constant = topLayoutGuide.length + pageViewTopSpaceConstant
                $0.bottomLayoutGuide.constant = bottomLayoutGuide.length + pageViewBottomSpaceConstant
            }
            view.layoutIfNeeded()
        }
        
        glowImageViewTopSpace.constant = pageViews.first!.imageView.convert(.zero, to: glowImageView.superview).y
    }
    
    // MARK: - Actions
    
    @IBAction
    private func submitButtonTapped() {
        let isLastPage = pageControl.currentPage == pageControl.numberOfPages - 1
        if isLastPage {
            completion()
        } else {
            paginating.setCurrentPageIndex(pageControl.currentPage + 1, animated: IsAnimationAllowed())
        }
    }
    
    // MARK: - Scroll View
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSubmitButtonTitleIfNeeded()
        updateGlowImagePosition()
    }
    
    private func updateGlowImagePosition() {
        let progress = scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width) - 0.5
        glowCenterX.constant = progress * 124
    }
    
    private func updateSubmitButtonTitleIfNeeded() {
        let isLastPage = pageControl.currentPage == pageControl.numberOfPages - 1
        let title = isLastPage ? "Готово" : "Далее"
        if submitButton.title(for: .normal) != title {
            submitButton.setTitle(title, for: .normal)
        }
    }
    
}
