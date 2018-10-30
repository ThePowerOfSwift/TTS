//
//  OrderTechServiceAppointmentViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

protocol OrderTechServiceAppointmentViewControllerDelegate: class {
    func orderTechServiceAppointmentViewController(_ viewController: OrderTechServiceAppointmentViewController, didCompleteWithAppointment appointment: OrderTechServiceAppointmentDTO)
}

final class OrderTechServiceAppointmentViewController: UIViewController, ErrorPresenting {
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentViewHeight: NSLayoutConstraint!
    @IBOutlet private var userAutoImageView: UIImageView!
    @IBOutlet private var userAutoTitleLabel: UILabel!
    @IBOutlet private var serviceCenterImageView: UIImageView!
    @IBOutlet private var serviceCenterAddressLabel: UILabel!
    @IBOutlet private var techServiceContainerView: UIView!
    @IBOutlet private var techServiceTextLabel: UILabel!
    @IBOutlet private var techServiceTextSeparator: UIView!
    @IBOutlet private var techServiceTotalTitleLabel: UILabel!
    @IBOutlet private var techServiceTotalTitleLabelBottomSpace: NSLayoutConstraint!
    @IBOutlet private var techServiceTotalPriceLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var fromLabel: UILabel!
    @IBOutlet private var toLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var submitButton: SubmitButton!
    
    weak var delegate: OrderTechServiceAppointmentViewControllerDelegate?
    private let interactor: OrderTechServiceAppointmentInteractorInput
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.ru_RU
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM y")
        return dateFormatter
    }()

    init(interactor: OrderTechServiceAppointmentInteractorInput) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateData()
        
        interactor.observeData { [weak self] in
            self?.data = $0
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
    
    private var data: OrderTechServiceAppointmentDTO? {
        didSet {
            updateData()
        }
    }
    
    private func updateData() {
        submitButton.setTitle(interactor.submitButtonTitle, for: .normal)
        
        // user auto
        if let auto = data?.userAuto {
            userAutoImageView.af_setImage(withURL: auto.image, filter: AspectScaledToFitSizeFilter(size: userAutoImageView.bounds.size))
            userAutoTitleLabel.text = auto.brand
        } else {
            userAutoImageView.af_cancelImageRequest()
            userAutoImageView.image = nil
            userAutoTitleLabel.text = nil
        }
        
        // service center
        if let serviceCenter = data?.serviceCenter {
            serviceCenterImageView.af_setImage(withURL: serviceCenter.image, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: serviceCenterImageView.bounds.size, radius: serviceCenterImageView.bounds.midX))
            serviceCenterAddressLabel.text = serviceCenter.cityName + ", " + serviceCenter.address
        } else {
            serviceCenterImageView.af_cancelImageRequest()
            serviceCenterImageView.image = nil
            serviceCenterAddressLabel.text = nil
        }
        
        // detail
        techServiceContainerView.layer.cornerRadius = 8
        techServiceTextLabel.attributedText = data?.description.with(StringAttributes {
            $0.foregroundColor = .white
            $0.font = .systemFont(ofSize: 15)
            $0.paragraphSpacing = 15
        })

        // price
        if let price = data?.price, case TechServicePrice.value(let number) = price {
            techServiceTotalPriceLabel.text = PriceFormatter().string(from: number)
            techServiceTotalPriceLabel.isHidden = false
            techServiceTextSeparator.isHidden = false
            techServiceTotalTitleLabel.isHidden = false
            techServiceTotalTitleLabelBottomSpace.constant = 20
        } else {
            techServiceTotalPriceLabel.text = nil
            techServiceTotalPriceLabel.isHidden = true
            techServiceTextSeparator.isHidden = true
            techServiceTotalTitleLabel.isHidden = true
            techServiceTotalTitleLabelBottomSpace.constant = -40
        }
        
        // period
        if let range = data?.period {
            title = dateFormatter.string(from: range.lowerBound)
            
            let timeFormatter = TimeFormatter()
            let durationFormatter = DurationFormatter()
            durationFormatter.calendar = Calendar.autoupdatingCurrent
            durationFormatter.calendar?.locale = Locale.ru_RU
            
            dateLabel.text = dateFormatter.string(from: range.lowerBound)
            fromLabel.text = timeFormatter.string(from: range.lowerBound)
            toLabel.text = timeFormatter.string(from: range.upperBound)
            durationLabel.text = durationFormatter.string(from: range)
        } else {
            dateLabel.text = nil
            fromLabel.text = nil
            toLabel.text = nil
            durationLabel.text = nil
        }
    }
    
    // MARK: - Actions
    
    @IBAction
    private func submitButtonTapped() {
        setIsLoading(true)
        interactor.sendData { [weak self] in
            self?.setIsLoading(false)
            if let error = $0 {
                self?.showError(error)
            } else {
                guard let `self` = self, let data = self.data else { return }
                self.delegate?.orderTechServiceAppointmentViewController(self, didCompleteWithAppointment: data)
            }
        }
        
    }
    
    // MARK: - Loading Indication
    
    private func setIsLoading(_ loading: Bool) {
        if loading {
            submitButton.startAnimating()
            submitButton.isEnabled = false
        } else {
            submitButton.stopAnimating()
            submitButton.isEnabled = true
        }
    }
    
}
