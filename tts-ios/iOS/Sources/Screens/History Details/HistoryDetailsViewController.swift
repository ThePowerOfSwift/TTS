//
//  HistoryDetailsViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

private let kDateFormatter: DateFormatter = {
    $0.locale = Locale.ru_RU
    $0.dateStyle = .long
    $0.timeStyle = .none
    return $0
}(DateFormatter())

final class HistoryDetailsViewController: ScrollViewController, ErrorPresenting, DataReloading {

    private let auto: UserAuto
    private let treatment: Treatment
    private let interactor: HistoryDetailsInteractor
    
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var autoImageView: UIImageView!
    @IBOutlet private var autoTitleLabel: UILabel!
    @IBOutlet private var orderNumberLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var serviceCenterContainerView: UIView!
    @IBOutlet private var serviceCenterImageView: UIImageView!
    @IBOutlet private var serviceCenterAddressLabel: UILabel!
    @IBOutlet private var masterImageView: UIImageView!
    @IBOutlet private var masterNameLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var mileageLabel: UILabel!
    @IBOutlet private var reasonLabel: UILabel!
    @IBOutlet private var starsControl: StarsRatingControl!
    private var subviewsBuilder: HistoryDetailsArrangedSubviewsBuilder!
    
    init(auto: UserAuto, treatment: Treatment, interactor: HistoryDetailsInteractor) {
        self.auto = auto
        self.treatment = treatment
        self.interactor = interactor
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Navigation Interface
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        navigationItem.title = kDateFormatter.string(from: treatment.date)
        return navigationItem
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subviewsBuilder = HistoryDetailsArrangedSubviewsBuilder(stackView: stackView)
        
        interactor.observeTreatmentDetail(treatmentId: treatment.id) { [weak self] in
            self?.response = $0
        }
        
        reloadData()
        
        starsControl.setStarsFillColor(UIColor(r: 56, g: 65, b: 88), forState: .normal)
        starsControl.setStarsFillColor(UIColor(r: 0, g: 148, b: 213), forState: .selected)
    }
    
    private func updateView(auto: UserAuto, response: GetTreatmentDetailResponse?) {
        let details = (response?.nomenclature ?? []) + (response?.jobs ?? [])
        let serviceCenter = response?.treatment?.serviceCenter
        
        let balanceFormatter = BalanceFormatter()
        balanceFormatter.locale = Locale.ru_RU
        
        autoImageView.af_setImage(withURL: auto.image, filter: AspectScaledToFitSizeFilter(size: autoImageView.bounds.size))
        autoTitleLabel.text = auto.brand
        orderNumberLabel.text = "Заказ-наряд № " + treatment.ordernum
        priceLabel.text = balanceFormatter.string(from: treatment.summ)
        serviceCenterContainerView.isHidden = serviceCenter == nil
        if let url = serviceCenter?.image {
            serviceCenterImageView.af_setImage(withURL: url, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: serviceCenterImageView.bounds.size, radius: serviceCenterImageView.bounds.midX))
        } else {
            serviceCenterImageView.af_cancelImageRequest()
            serviceCenterImageView.image = nil
        }
        serviceCenterAddressLabel.text = serviceCenter?.address
        masterImageView.af_setImage(withURL: treatment.masterPhoto, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: masterImageView.bounds.size, radius: masterImageView.bounds.midX))
        masterNameLabel.text = treatment.master
        dateLabel.text = kDateFormatter.string(from: treatment.date)
        mileageLabel.text = treatment.mileage.stringValue
        reasonLabel.text = treatment.reason
        starsControl.numberOfSelectedStars = 4
        
        subviewsBuilder.removeSubviewsFromSuperview()
        
        let jobs = details.filter({$0.type == .job})
        let nomenclature = details.filter({$0.type == .nomenclature})

        balanceFormatter.numberStyle = .decimal
        
        // работы
        do {
            if jobs.count > 0 {
                subviewsBuilder.addHeaderSubview(title: "Работы", detail: "₽")
                subviewsBuilder.addSeparatorSubview()
            }
            for detail in jobs {
                subviewsBuilder.addDetailSubview(title: detail.name, detail: balanceFormatter.string(from: detail.summ))
            }
        }
        
        // материалы
        do {
            if nomenclature.count > 0 {
                subviewsBuilder.addHeaderSubview(title: "Материалы", detail: "₽")
                subviewsBuilder.addSeparatorSubview()
            }
            for detail in nomenclature {
                subviewsBuilder.addDetailSubview(title: detail.name, detail: balanceFormatter.string(from: detail.summ))
            }
        }
        
        // всего работы и материалы
        if jobs.count > 0 || nomenclature.count > 0 {
            subviewsBuilder.addSeparatorSubview()
        }
        if jobs.count > 0 {
            subviewsBuilder.addDetailSubview(title: "Работы", detail: balanceFormatter.string(from: jobs.summ))
        }
        if nomenclature.count > 0 {
            subviewsBuilder.addDetailSubview(title: "Материалы", detail: balanceFormatter.string(from: nomenclature.summ))
        }
        
        // итого
        if details.count > 0 {
            subviewsBuilder.addSeparatorSubview()
            subviewsBuilder.addTotalSubview(detail: balanceFormatter.string(from: treatment.summ))
            subviewsBuilder.addSpacerSubview(height: 8)
        }
    }
    
    // MARK: - Treatment Details
    
    private var response: GetTreatmentDetailResponse? {
        didSet {
            guard isViewLoaded else { return }
            updateView(auto: auto, response: response)
        }
    }
    
    // MARK: - Data Loading
    
    func reloadData() {
        setIsLoading(true)
        interactor.reloadData(treatmentId: treatment.id) { [weak self] in
            self?.setIsLoading(false)
            if let error = $0.error {
                self?.showError(error)
            }
        }
    }

    private func setIsLoading(_ loading: Bool) {
        if loading {
            if stackView.arrangedSubviews.first(where: {$0 is UIActivityIndicatorView}) == nil {
                let spinner = UIActivityIndicatorView(style: .white)
                spinner.startAnimating()
                stackView.addArrangedSubview(spinner)
            }
        } else {
            let spinner = stackView.arrangedSubviews.first {$0 is UIActivityIndicatorView}
            spinner?.removeFromSuperview()
        }
    }
    
}
