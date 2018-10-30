//
//  AddCarStep3ViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import AlamofireImage

protocol AddCarStep3ViewControllerDelegate: class {
    func addCarStep3ViewController(_ viewController: AddCarStep3ViewController, didSelectCellWithCity city: NamedValue?)
    func addCarStep3ViewController(_ viewController: AddCarStep3ViewController, didSelectServiceCenterCellWithBrand brand: CarBrand, city: NamedValue, serviceCenter: ServiceCenter?)
    func addCarStep3ViewControllerDidComplete(_ viewController: AddCarStep3ViewController)
}

final class AddCarStep3ViewController: UIViewController, ErrorPresenting, ListAdapterDataSource {
    
    weak var delegate: AddCarStep3ViewControllerDelegate?
    private let interactor: AddCarStep3Interactor
    private let brand: CarBrand
    private let modelId: Int
    private let year: Int
    private let gosnomer: String
    private let vin: String
    private let mileage: Int

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var progressViewTopSpace: NSLayoutConstraint!
    @IBOutlet private var submitButton: SubmitButton!
    
    private var adapter: ListAdapter!
    
    init(interactor: AddCarStep3Interactor, brand: CarBrand, modelId: Int, year: Int, gosnomer: String, vin: String, mileage: Int) {
        self.interactor = interactor
        self.brand = brand
        self.modelId = modelId
        self.year = year
        self.gosnomer = gosnomer
        self.vin = vin
        self.mileage = mileage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = view.backgroundColor
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearSelectionWhenInteractionEnds(for: collectionView, animated: IsAnimationAllowed())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.flashScrollIndicators()
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        progressViewTopSpace.constant = topLayoutGuide.length
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = [AddCarStepItem(currentStep: 3, maxSteps: 3)]
        
        do { // city
            result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: nil, title: "Город", detail: city?.name)) { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.addCarStep3ViewController(self, didSelectCellWithCity: self.city)
            })
        }

        do { // service center
            let image = serviceCenter.flatMap { ListBasicLayout.Image.url($0.image, filter: AspectScaledToFillSizeCircleFilter(size: CGSize(width: 40, height: 40)))}
            result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: image, title: "Сервисный центр", detail: serviceCenter?.address)) { [weak self] in
                guard let `self` = self else { return }
                if let city = self.city {
                    self.delegate?.addCarStep3ViewController(self, didSelectServiceCenterCellWithBrand: self.brand, city: city, serviceCenter: self.serviceCenter)
                } else {
                    self.presentServiceCenterSelectError()
                }
            })
        }
        
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is AddCarStepItem {
            return AddCarStepSectionController()
        } else if object is ListBasicItem {
            return ListBasicSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - Managing Submit Button
    
    private func updateSubmitButtonState() {
        let isEnabled = city != nil
        submitButton.isEnabled = isEnabled
    }
    
    @IBAction
    private func submitButtonTapped() {
        sendAddAutoRequest()
    }
    
    // MARK: - Managing Data
    
    private var city: NamedValue?
    
    func setCity(_ value: NamedValue?) {
        city = value
        serviceCenter = nil
        adapter.reloadData(completion: nil)
        updateSubmitButtonState()
    }

    private var serviceCenter: ServiceCenter?
    
    func setServiceCenter(_ value: ServiceCenter?) {
        serviceCenter = value
        adapter.reloadData(completion: nil)
        updateSubmitButtonState()
    }
    
    // MARK: - Adding Auto
    
    private func sendAddAutoRequest() {
        setIsLoading(true)
        interactor.addUserAuto(brandId: brand.id, modelId: modelId, complectationId: nil, year: year, gosnomer: gosnomer, vin: vin, mileage: mileage, serviceId: serviceCenter?.uid) { [weak self] in
            self?.setIsLoading(false)
            if let error = $0 {
                self?.showError(error)
            } else {
                guard let `self` = self else { return }
                self.delegate?.addCarStep3ViewControllerDidComplete(self)
            }
        }
    }
    
    // MARK: - Loading State
    
    private func setIsLoading(_ loading: Bool) {
        submitButton.isUserInteractionEnabled = !loading
        loading ? submitButton.startAnimating() : submitButton.stopAnimating()
    }
    
    // MARK: - Presenting Error
    
    private func presentServiceCenterSelectError() {
        showError(title: "Чтобы выбрать сервисный центр, нужно сначала заполнить предыдущие поля", message: nil, animated: IsAnimationAllowed(), close: { [weak self] in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
            }, completion: nil)
    }
    
}
