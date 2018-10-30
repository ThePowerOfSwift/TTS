//
//  GarageMainEmptyViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit

protocol GarageMainEmptyViewControllerDelegate: class {
    func garageMainEmptyViewControllerDidTapAddCarButton(_ viewController: GarageMainEmptyViewController)
}

final class GarageMainEmptyViewController: UIViewController, ListAdapterDataSource {

    weak var delegate: GarageMainEmptyViewControllerDelegate?
    private var collectionView: UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    private var adapter: ListAdapter!
    private let call: CallAction
    
    init(call: CallAction) {
        self.call = call
        super.init(nibName: nil, bundle: nil)
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
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            collectionView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            collectionView.scrollIndicatorInsets = collectionView.contentInset
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adapter.reloadData(completion: nil)
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let phone = CallAction.hotLinePhoneNumber
        
        var items: [ListDiffable & HeightCalculatable] = [
            GarageMainAddUserAutoItem(buttonTapped: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.garageMainEmptyViewControllerDidTapAddCarButton(self)
            }),
            GarageMainServiceNameItem.hotLineItem(backgroundColor: view.backgroundColor),
            ListRightImageItem(text: PhoneNumberFormatter().string(from: phone), image: #imageLiteral(resourceName: "icn_global_call"), textColor: .white, backgroundColor: UIColor(r: 37, g: 42, b: 57), selected: { [weak self] in
                self?.call.call(phone: phone, title: "Горячая линия", completion: { _ in
                    self?.collectionView.deselectAll(animated: IsAnimationAllowed())
                })
            })
        ]

        let carItemHeight = collectionView.boundsSizeWithContentInsetExcluded.height - (items as [HeightCalculatable]).height(forWidth: collectionView.bounds.width)
        items.insert(GarageMainCarItem(auto: nil, proposedHeight: carItemHeight, onService: nil, onRepair: nil, onPrice: nil), at: 1)
        
        return items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is GarageMainAddUserAutoItem {
            return GarageMainAddUserAutoSectionController()
        } else if object is GarageMainCarItem {
            return GarageMainCarSectionController()
        } else if object is GarageMainServiceNameItem {
            return GarageMainServiceNameSectionController()
        } else if object is ListRightImageItem {
            return ListRightImageSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}
