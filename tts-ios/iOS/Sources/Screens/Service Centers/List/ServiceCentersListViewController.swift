//
//  ServiceCentersListViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import IGListKit
import TTSKit

final class ServiceCentersListViewController: CollectionViewController, IndicatorInfoProvider, ServiceCentersFilterable {
    
    private var myServicesCollectionView: UICollectionView?
    private let interactor: ServiceCentersListInteractor
    
    init(interactor: ServiceCentersListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 37, g: 42, b: 57)

        collectionView.alwaysBounceVertical = true
        
        setIsLoading(true)
        observeData(brand: brand, city: city)
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let myServicesCollectionView = myServicesCollectionView {
            clearSelectionWhenInteractionEnds(for: myServicesCollectionView, animated: IsAnimationAllowed())
        }
    }
    
    // MARK: - Providing Indicator Info
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Список")
    }
    
    // MARK: - List Adapter
    
    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] { // swiftlint:disable:this cyclomatic_complexity
        var items = [ListDiffable]()
        
        let groups = data?.0
        let location = data?.1
        
        // мои сервисы
        if let myServices = groups?.flatMap({ $0.services.filter {($0.auto?.count ?? 0) > 0} }), myServices.count > 0 {
            let pairs = myServices.reduce(into: [ServiceCenterUserAutoLightPair]()) { result, service in
                for auto in service.auto ?? [] {
                    result.append(ServiceCenterUserAutoLightPair(service: service, auto: auto))
                }
            }
            items.append(ServiceCentersListHeaderItem(text: "Мои сервисы"))
            items.append(ServiceCentersListMyServicesItem(pairs: pairs, didConfigure: { [weak self] in
                self?.myServicesCollectionView = $0.collectionView
            }, didSelect: { [weak self] in
                self?.didSelectMyServiceCenter($0)
            }))
        }
        
        // все сервисы
        if let groups = groups, groups.count > 0 {
            items.append(ServiceCentersListHeaderItem(text: "Все сервисы"))

            if let location = location {
                let dictionary = Dictionary(grouping: groups, by: { element -> String in
                    let distance = location.distance(from: CLLocation(coordinate: element.coordinate))
                    switch distance {
                    case 0...10000:
                        return "1-10 км"
                    default:
                        return "более 10 км"
                    }
                })
                if dictionary.count > 0 {
                    for (key, value) in dictionary {
                        items.append(ServiceCentersListHeaderItem(text: key))
                        for group in value {
                            items.append(ServiceCentersListServiceItem(group: group, didSelect: { [weak self] in
                                self?.didSelectServiceCenterGroup($0)
                            }))
                        }
                    }
                } else {
                    for group in groups {
                        items.append(ServiceCentersListServiceItem(group: group, didSelect: { [weak self] in
                            self?.didSelectServiceCenterGroup($0)
                        }))
                    }
                }
            } else {
                for group in groups {
                    items.append(ServiceCentersListServiceItem(group: group, didSelect: { [weak self] in
                        self?.didSelectServiceCenterGroup($0)
                    }))
                }
            }
        }
            
        return items
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ServiceCentersListHeaderItem {
            return ServiceCentersListHeaderSectionController()
        } else if object is ServiceCentersListMyServicesItem {
            return ServiceCentersListMyServicesSectionController()
        } else if object is ServiceCentersListServiceItem {
            return ServiceCentersListServiceSectionController()
        } else {
            fatalError()
        }
    }
    
    // MARK: - Managing Items
    
    private func observeData(brand: CarBrand?, city: NamedValue?) {
        interactor.observeData(brand: brand, city: city, onNext: { [weak self] in
            self?.data = $0
            if $0.0.count > 0 {
                self?.setIsLoading(false)
            }
        })
    }
    
    private var data: ([ServiceCenterGroup], CLLocation?)? {
        didSet {
            guard isViewLoaded else { return }
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    private func didSelectMyServiceCenter(_ pair: ServiceCenterUserAutoLightPair) {
        presentServiceCenterGroupViewController(serviceId: pair.service.id, selectedBrandId: nil)
    }
    
    private func didSelectServiceCenterGroup(_ group: ServiceCenterGroup) {
        presentServiceCenterGroupViewController(latitude: group.coordinatesLatitude, longitude: group.coordinatesLongitude, selectedBrandId: nil)
    }
    
    // MARK: - Presenting Service Centers Group Screen
    
    private func presentServiceCenterGroupViewController(serviceId: Int, selectedBrandId: Int?) {
        let interactor = self.interactor.createServiceCenterGroupTabsInteractor(serviceId: serviceId)
        let viewController = ServiceCenterGroupTabsViewController(interactor: interactor, selectedBrandId: selectedBrandId)
        show(viewController, sender: nil)
    }
    
    private func presentServiceCenterGroupViewController(latitude: String, longitude: String, selectedBrandId: Int?) {
        let interactor = self.interactor.createServiceCenterGroupTabsInteractor(latitude: latitude, longitude: longitude)
        let viewController = ServiceCenterGroupTabsViewController(interactor: interactor, selectedBrandId: selectedBrandId)
        show(viewController, sender: nil)
    }
    
    // MARK: - Filtering Service Centers
    
    private var brand: CarBrand?
    private var city: NamedValue?
    
    func applyFilter(brand: CarBrand?, city: NamedValue?) {
        self.brand = brand
        self.city = city
        observeData(brand: brand, city: city)
    }
    
    // MARK: - Loading Indication
    
    private var spinner: UIActivityIndicatorView?
    
    private func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            let spinner = self.spinner ?? UIActivityIndicatorView(style: .white)
            spinner.frame = CGRect(x: round(view.bounds.midX), y: 20, width: spinner.bounds.width, height: spinner.bounds.height)
            spinner.autoresizingMask = .flexibleMargins
            spinner.startAnimating()
            view.addSubview(spinner)
            self.spinner = spinner
        } else {
            spinner?.removeFromSuperview()
        }
    }
    
}
