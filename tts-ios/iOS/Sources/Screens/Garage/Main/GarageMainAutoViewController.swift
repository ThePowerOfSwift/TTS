//
//  GarageMainAutoViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import XLPagerTabStrip

final class GarageMainAutoViewController: UIViewController, ListAdapterDataSource, IndicatorInfoProvider {

    private var collectionView: UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    private var adapter: ListAdapter!
    private let interactor: GarageMainAutoInteractor
    private let call: CallAction
    private let onService: (UserAuto) -> Void
    private let onRepair: (UserAuto) -> Void
    private let onPrice: (UserAuto) -> Void
    
    init(title: String, interactor: GarageMainAutoInteractor, call: CallAction, onService: @escaping (UserAuto) -> Void, onRepair: @escaping (UserAuto) -> Void, onPrice: @escaping (UserAuto) -> Void) {
        self.interactor = interactor
        self.call = call
        self.onService = onService
        self.onPrice = onPrice
        self.onRepair = onRepair
        super.init(nibName: nil, bundle: nil)
        self.title = title

        interactor.observeAuto { [weak self] in
            self?.auto = $0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = .flexibleDimensions
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        
        let footer = InfiniteScrollViewFooter()
        footer.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        collectionView.addSubview(footer)
        
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
    
    // MARK: - Autos
    
    private(set) var auto: UserAuto? {
        didSet {
            if isViewLoaded {
                adapter.reloadData(completion: nil)
            }
        }
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let backgroundColor = UIColor(r: 37, g: 42, b: 57)
        
        var items = [ListDiffable & HeightCalculatable]()

        if let auto = auto, let serviceCenter = auto.serviceCenter {
            var lastBackgroundColor = view.backgroundColor
            
            for record in auto.records ?? [] {
                let item = GarageMainTechServiceRecordItem(record: record, backgroundColor: lastBackgroundColor, select: { [weak self] in
                    self?.presentOrderTechServiceAppointmentViewController(record: record)
                })
                items.append(item)
                lastBackgroundColor = item.cardColor
            }
            
            // service center name
            do {
                let item = GarageMainServiceNameItem(name: "Мой сервис " + auto.brand, backgroundColor: lastBackgroundColor)
                items.append(item)
                lastBackgroundColor = item.cardColor
            }
            
            // service center address
            items.append(ListBasicItem(layout: .init(title: .init(title: serviceCenter.cityName + ", " + serviceCenter.address, font: .systemFont(ofSize: 15, weight: .light)), background: .init(fillColor: backgroundColor)), selected: { [weak self] in
                self?.presentServiceCenterGroupViewController(serviceId: serviceCenter.id, selectedBrandId: auto.brandId)
            }))
            if let phone = serviceCenter.phone.first {
                items.append(ListRightImageItem(text: PhoneNumberFormatter().string(from: phone), image: #imageLiteral(resourceName: "icn_global_call"), textColor: .white, backgroundColor: backgroundColor, selected: { [weak self] in
                    guard let `self` = self else { return }
                    self.call.call(phone: phone, title: "Мой сервис " + auto.brand, completion: { [weak self] _ in
                        self?.collectionView.deselectAll(animated: IsAnimationAllowed())
                    })
                }))
            }
        } else {
            items.append(GarageMainServiceNameItem.hotLineItem(backgroundColor: view.backgroundColor))
            let phone = CallAction.hotLinePhoneNumber
            items.append(ListRightImageItem(text: PhoneNumberFormatter().string(from: phone), image: #imageLiteral(resourceName: "icn_global_call"), textColor: .white, backgroundColor: backgroundColor, selected: { [weak self] in
                guard let `self` = self else { return }
                self.call.call(phone: phone, title: "Служба поддержки", completion: { [weak self] _ in
                    self?.collectionView.deselectAll(animated: IsAnimationAllowed())
                })
            }))
        }
        
        let carItemHeight = collectionView.boundsSizeWithContentInsetExcluded.height - (items as [HeightCalculatable]).height(forWidth: collectionView.bounds.width)
        items.insert(GarageMainCarItem(auto: auto, proposedHeight: carItemHeight, onService: { [weak self] in
            guard let `auto` = self?.auto else { return }
            self?.onService(auto)
        }, onRepair: { [weak self] in
            guard let `auto` = self?.auto else { return }
            self?.onRepair(auto)
        }, onPrice: { [weak self] in
            guard let `auto` = self?.auto else { return }
            self?.onPrice(auto)
        }), at: 0)
        
        return items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is GarageMainCarItem {
            return GarageMainCarSectionController()
        } else if object is GarageMainTechServiceRecordItem {
            return GarageMainTechServiceRecordSectionController()
        } else if object is GarageMainServiceNameItem {
            return GarageMainServiceNameSectionController()
        } else if object is ListBasicItem {
            return ListBasicSectionController()
        } else if object is ListRightImageItem {
            return ListRightImageSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - Providing Indicator Info
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: title)
    }
    
    // MARK: - Presenting Service Center Screen
    
    private func presentServiceCenterGroupViewController(serviceId: Int, selectedBrandId: Int?) {
        let interactor = self.interactor.createServiceCenterGroupTabsInteractor(serviceId: serviceId)
        let viewController = ServiceCenterGroupTabsViewController(interactor: interactor, selectedBrandId: selectedBrandId)
        show(viewController, sender: nil)
    }
    
}

extension GarageMainAutoViewController: OrderTechServiceAppointmentViewControllerDelegate {
    
    private func presentOrderTechServiceAppointmentViewController(record: TechServiceRecord) {
        guard let serviceCenter = auto?.serviceCenter else { return }
        let interactor = self.interactor.createOrderTechServiceAppointmentCancelInteractor(serviceCenter: serviceCenter, record: record)
        let viewController = OrderTechServiceAppointmentViewController(interactor: interactor)
        viewController.delegate = self
        viewController.hidesBottomBarWhenPushed = true
        show(viewController, sender: nil)
    }
    
    func orderTechServiceAppointmentViewController(_ viewController: OrderTechServiceAppointmentViewController, didCompleteWithAppointment appointment: OrderTechServiceAppointmentDTO) {
        presentOrderTechServiceAppointmentDidCancelMessage { [weak viewController] in
            viewController?.navigationController?.popViewController(animated: IsAnimationAllowed())
        }
    }
    
    private func presentOrderTechServiceAppointmentDidCancelMessage(close: (() -> Void)?) {
        let viewController = UIAlertController(title: "Запись в СЦ отменена", message: nil, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in
            close?()
        }))
        navigationController?.present(viewController, animated: IsAnimationAllowed())
    }
    
}
