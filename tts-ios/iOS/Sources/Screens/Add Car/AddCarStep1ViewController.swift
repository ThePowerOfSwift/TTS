//
//  AddCarStep1ViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import AlamofireImage

protocol AddCarStep1ViewControllerDelegate: class {
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didSelectCellWithBrand brand: CarBrand?, model: NamedValue?)
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didSelectCellWithYear year: Int?)
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didSelectCellWithEquipment equipment: CarEquipment?, brandId: Int, modelId: Int, year: Int)
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didCompleteWithBrand brand: CarBrand, modelId: Int, year: Int, complectationId: Int?)
}

final class AddCarStep1ViewController: UIViewController, ListAdapterDataSource, ErrorPresenting {

    weak var delegate: AddCarStep1ViewControllerDelegate?
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var progressViewTopSpace: NSLayoutConstraint!
    @IBOutlet private var submitButton: SubmitButton!
    
    private var adapter: ListAdapter!

    init() {
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
        title = "Добавление авто"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset.bottom = submitButton.bounds.height
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        updateSubmitButtonState()
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
                
        adapter.reloadData(completion: nil)
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = [AddCarStepItem(currentStep: 1, maxSteps: 3)]
        
        do { // brand + car
            let image = carBrand?.image.flatMap { ListBasicLayout.Image.url($0, filter: AspectScaledToFillSizeFilter(size: CGSize(width: 40, height: 40))) }
            let detail = carBrand.flatMap({ brand in carModel.flatMap { model in brand.name + " " + model.name } })
            result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: image, title: "Авто", detail: detail)) { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.addCarStep1ViewController(self, didSelectCellWithBrand: self.carBrand, model: self.carModel)
            })
        }
        
        do { // year
            let detail = carYear.flatMap { String($0) }
            result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: nil, title: "Год выпуска", detail: detail)) { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.addCarStep1ViewController(self, didSelectCellWithYear: self.carYear)
            })
        }
        
        do { // equipment
            result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: nil, title: "Комплектация", detail: carEquipment?.name)) { [weak self] in
                guard let `self` = self else { return }
                if let brandId = self.carBrand?.id, let modelId = self.carModel?.id, let year = self.carYear {
                    self.delegate?.addCarStep1ViewController(self, didSelectCellWithEquipment: self.carEquipment, brandId: brandId, modelId: modelId, year: year)
                } else {
                    self.presentEquipmentSelectionError()
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
        let isEnabled = carBrand != nil && carModel != nil && carYear != nil
        submitButton.isEnabled = isEnabled
    }
    
    @IBAction
    private func submitButtonTapped() {
        guard let brand = carBrand, let model = carModel, let year = carYear else { return }
        let complectationId: Int? = carEquipment?.id == nil ? nil : NumberFormatter().number(from: carEquipment!.id)?.intValue
        delegate?.addCarStep1ViewController(self, didCompleteWithBrand: brand, modelId: model.id, year: year, complectationId: complectationId)
    }
    
    // MARK: - Managing Data
    
    private var carBrand: CarBrand?
    private var carModel: NamedValue?
    
    func setCarBrandAndModel(_ value: (CarBrand, NamedValue)?) {
        carBrand = value?.0
        carModel = value?.1
        carEquipment = nil
        adapter.reloadData(completion: nil)
        updateSubmitButtonState()
    }
    
    private var carYear: Int?
    
    func setCarYear(_ value: Int?) {
        carYear = value
        carEquipment = nil
        adapter.reloadData(completion: nil)
        updateSubmitButtonState()
    }
    
    private var carEquipment: CarEquipment?
    
    func setEquipment(_ value: CarEquipment?) {
        carEquipment = value
        adapter.reloadData(completion: nil)
        updateSubmitButtonState()
    }
    
    // MARK: - Presenting Error
    
    private func presentEquipmentSelectionError() {
        showError(title: "Чтобы выбрать комплектацию, нужно сначала заполнить предыдущие поля", message: nil, animated: IsAnimationAllowed(), close: { [weak self] in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
            }, completion: nil)
    }
    
}
