//
//  ServiceCentersFilterViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import AlamofireImage

final class ServiceCentersFilterViewController: UIViewController, ListAdapterDataSource {
    
    private var adapter: ListAdapter!
    private let interactor: ServiceCentersFilterInteractor
    private let apply: (CarBrand?, NamedValue?) -> Void
    private let close: () -> Void
    private let brandSelected: (CarBrand?) -> Void
    private let citySelected: (NamedValue?) -> Void
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var submitButton: SubmitButton!
    
    init(interactor: ServiceCentersFilterInteractor, brandSelected: @escaping (CarBrand?) -> Void, citySelected: @escaping (NamedValue?) -> Void, apply: @escaping (CarBrand?, NamedValue?) -> Void, close: @escaping () -> Void) {
        self.interactor = interactor
        self.brandSelected = brandSelected
        self.citySelected = citySelected
        self.apply = apply
        self.close = close
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Navigation Interface
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        navigationItem.title = "Фильтр"
        if navigationItem.leftBarButtonItem == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_close"), style: .plain) { [weak self] in
                self?.close()
            }
        }
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить", style: .plain, target: self, action: #selector(clear))
        }
        return navigationItem
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset.bottom = submitButton.bounds.height
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearSelectionWhenInteractionEnds(for: collectionView, animated: IsAnimationAllowed())
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adapter.reloadData(completion: nil)
    }
    
    // MARK: - Managing the Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result = [ListDiffable]()
        
        do { // brand
            let image = carBrand?.image.flatMap { ListBasicLayout.Image.url($0, filter: AspectScaledToFillSizeFilter(size: CGSize(width: 40, height: 40))) }
            result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: image, title: "Выберите марку автомобиля", detail: carBrand?.name)) { [weak self] in
                self?.brandSelected(self?.carBrand)
            })
        }

        do { // city
            result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: nil, title: "Выберите город", detail: city?.name)) { [weak self] in
                self?.citySelected(self?.city)
            })
        }
        
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ListBasicItem {
            return ListBasicSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - Managing Data
    
    private var carBrand: CarBrand?
    private var city: NamedValue?
    
    func setCity(_ value: NamedValue?) {
        city = value
        if isViewLoaded {
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    func setBrand(_ value: CarBrand?) {
        carBrand = value
        if isViewLoaded {
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    // MARK: - Clearing Data
    
    @objc
    private func clear() {
        city = nil
        carBrand = nil
        if isViewLoaded {
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    // MARK: - Managing Submit Button
    
    @IBAction
    private func submitButtonTapped() {
        apply(carBrand, city)
    }
    
}
