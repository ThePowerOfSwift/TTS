//
//  OrderTechServiceListViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

final class OrderTechServiceListViewController: CollectionViewController, ErrorPresenting {
    
    private let interactor: OrderTechServiceListInteractor
    internal var onSelect: ((OrderTechServiceGetListResponse.Service) -> Void)?
    
    init(interactor: OrderTechServiceListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = "Выбрать номер ТО"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        interactor.observeData { [weak self] in
            self?.list = $0
        }
    }
    
    // MARK: - List Adapter
    
    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        
        for service in list?.to ?? [] {
            result.append(ListBasicItem(layout: .init(title: .init(title: service.name), isChevronHidden: true), selected: { [weak self] in
                self?.onSelect?(service)
            }))
        }
        
        return result
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ListBasicItem {
            return ListBasicSectionController()
        } else {
            fatalError()
        }
    }
    
    // MARK: - Managing Data
    
    private var list: OrderTechServiceGetListResponse? {
        didSet {
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
}
