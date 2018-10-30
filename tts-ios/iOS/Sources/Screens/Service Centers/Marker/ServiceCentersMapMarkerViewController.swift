//
//  ServiceCentersMapMarkerViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 28/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import AlamofireImage

final class ServiceCentersMapMarkerViewController: CollectionViewController {

    private let interactor: ServiceCentersMapMarkerInteractor
    private let call: CallAction
    
    init(interactor: ServiceCentersMapMarkerInteractor, call: CallAction) {
        self.interactor = interactor
        self.call = call
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 37, g: 42, b: 57)
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize.height = (objectsForListAdapter() as? [HeightCalculatable])?.height(forWidth: collectionView.bounds.width) ?? 0
    }
    
    // MARK: - List Adapter
    
    private func objectsForListAdapter() -> [ListDiffable] {
        guard let group = group else { return [] }
        
        var items = [ListDiffable & HeightCalculatable]()
        
        // address
        do {
            items.append(ListBasicItem(layout: .init(title: .init(title: group.address, font: .systemFont(ofSize: 15, weight: .light)))) { [weak self] in
                self?.presentServiceCentersGroupViewController(latitude: group.coordinatesLatitude, longitude: group.coordinatesLongitude, selectedBrandId: nil)
            })
        }
        
        let autos = group.autos
        
        // phone or brands
        if group.services.count == 1 {
            let service = group.services[0]
            let text = service.phone.map { PhoneNumberFormatter().string(from: $0) }.joined(separator: ", ")
            items.append(ListRightImageItem(text: text, image: #imageLiteral(resourceName: "icn_global_call"), textColor: .white, font: .systemFont(ofSize: 17, weight: .light), backgroundColor: nil, selected: { [weak self] in
                guard let phone = service.phone.first, let brand = service.brandName else { return }
                self?.call.call(phone: phone, title: "Мой сервис " + brand, completion: { [weak self] _ in
                    self?.collectionView.deselectAll(animated: IsAnimationAllowed())
                })
            }))
        } else if autos.count == 0 {
            items.append(ServiceCentersGroupItem(group: group, separatorStyle: .none))
        }
        
        // auto
        for auto in autos {
            items.append(ListBasicItem(id: auto.id, layout: .init(image: .url(auto.image, filter: AspectScaledToFitSizeFilter(size: CGSize(width: 40, height: 40))), title: .init(title: auto.brand, font: .systemFont(ofSize: 15, weight: .bold)), separatorStyle: .inset(.custom(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))), isChevronHidden: true), selected: nil))
        }

        return items
    }
    
    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return objectsForListAdapter()
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ListBasicItem {
            return ListBasicSectionController()
        } else if object is ServiceCentersGroupItem {
            return ServiceCentersGroupSectionController()
        } else if object is ListRightImageItem {
            return ListRightImageSectionController()
        } else {
            fatalError()
        }
    }
    
    // MARK: - Configuring Group
    
    func setServiceCenterGroup(latitude: String, longitude: String) {
        interactor.observe(latitude: latitude, longitude: longitude) { [weak self] in
            self?.group = $0
        }
    }
    
    private var group: ServiceCenterGroup? {
        didSet {
            guard isViewLoaded else { return }
            adapter.performUpdates(animated: false, completion: nil)
            view.setNeedsLayout()
        }
    }
    
    // MARK: - Presenting Service Center
    
    private func presentServiceCentersGroupViewController(latitude: String, longitude: String, selectedBrandId: Int?) {
        let interactor = self.interactor.createServiceCenterGroupTabsInteractor(latitude: latitude, longitude: longitude)
        let viewController = ServiceCenterGroupTabsViewController(interactor: interactor, selectedBrandId: selectedBrandId)
        show(viewController, sender: nil)
    }
    
}
