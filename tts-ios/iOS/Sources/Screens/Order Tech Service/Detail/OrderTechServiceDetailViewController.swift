//
//  OrderTechServiceDetailViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

protocol OrderTechServiceDetailViewControllerDelegate: class {
    func orderTechServiceDetailViewController(_ viewController: OrderTechServiceDetailViewController, didConfirmService service: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail)
}

final class OrderTechServiceDetailViewController: UIViewController {
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentViewHeight: NSLayoutConstraint!
    @IBOutlet private var priceContainerViewHeight: NSLayoutConstraint!
    @IBOutlet private var priceDescriptionLabel: UILabel!
    @IBOutlet private var priceValueLabel: UILabel!
    @IBOutlet private var descriptionTitleContainerView: UIView!
    @IBOutlet private var descriptionTextContainerView: UIView!
    @IBOutlet private var descriptionTextLabel: UILabel!
    @IBOutlet private var submitButton: SubmitButton!
    
    weak var delegate: OrderTechServiceDetailViewControllerDelegate?
    private let interactor: OrderTechServiceDetailInteractor
    
    init(interactor: OrderTechServiceDetailInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDetail()
        
        interactor.observeData { [weak self] in
            self?.response = ($0, $1)
        }
    }
    
    // MARK: - Responding to View Events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.flashScrollIndicators()
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var contentInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            contentInset = .zero
        } else {
            contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        }
        contentInset.top += 27
        contentInset.bottom += submitButton.bounds.height
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets.bottom = scrollView.contentInset.bottom
        
        if #available(iOS 11.0, *) {
            contentViewHeight.constant = -(scrollView.adjustedContentInset.top + scrollView.adjustedContentInset.bottom)
        } else {
            contentViewHeight.constant = -(scrollView.contentInset.top + scrollView.contentInset.bottom)
        }
    }
    
    // MARK: - Managing the Data
    
    private var response: (OrderTechServiceGetListResponse.Service, OrderTechServiceGetDetailResponse.Detail)? {
        didSet {
            updateDetail()
        }
    }
    
    private func updateDetail() {
        let detail = response?.1
        
        title = detail?.name
        
        if let total = detail?.total, case TechServicePrice.value(let number) = total {
            priceContainerViewHeight.constant = 44
            priceValueLabel.isHidden = false
            priceDescriptionLabel.isHidden = true
            priceValueLabel.text = PriceFormatter().string(from: number)
        } else {
            priceContainerViewHeight.constant = 62
            priceValueLabel.isHidden = true
            priceDescriptionLabel.isHidden = false
        }
        
        if let description = detail?.description, description.count > 0 {
            let strings = description.map { $0.operation }
            descriptionTextLabel.attributedText = strings.joined(separator: "\n").with(StringAttributes {
                $0.foregroundColor = .white
                $0.font = .systemFont(ofSize: 15)
                $0.paragraphSpacing = 15
            })
            descriptionTitleContainerView.isHidden = false
            descriptionTextContainerView.isHidden = false
        } else {
            descriptionTitleContainerView.isHidden = true
            descriptionTextContainerView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction
    private func submitButtonTapped() {
        guard let response = response else { return }
        delegate?.orderTechServiceDetailViewController(self, didConfirmService: response.0, detail: response.1)
    }
    
}
