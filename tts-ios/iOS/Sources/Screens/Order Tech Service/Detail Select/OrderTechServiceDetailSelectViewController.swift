//
//  OrderTechServiceDetailSelectViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

protocol OrderTechServiceDetailSelectViewControllerDelegate: class {
    func orderTechServiceDetailSelectViewController(_ viewController: OrderTechServiceDetailSelectViewController, didSelectService service: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail)
}

final class OrderTechServiceDetailSelectViewController: CollectionViewController, ErrorPresenting {
    
    weak var delegate: OrderTechServiceDetailSelectViewControllerDelegate?
    private let interactor: OrderTechServiceDetailSelectInteractor
    
    init(interactor: OrderTechServiceDetailSelectInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = "Выбрать вид ТО"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        collectionView.alwaysBounceVertical = true
        
        interactor.observeData { [weak self] in
            self?.response = ($0, $1)
        }
    }
    
    // MARK: - List Adapter
    
    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        
        let details = response?.1
        
        if let detail = details?.standard {
            result.append(ListBasicItem(layout: .init(title: .init(title: detail.name), detail: .init(detail: "ТО рекомендуемое дистрибьютором")), selected: { [weak self] in
                guard let `self` = self, let service = self.response?.0 else { return }
                self.delegate?.orderTechServiceDetailSelectViewController(self, didSelectService: service, detail: detail)
            }))
        }
        
        if let detail = details?.econom {
            result.append(ListBasicItem(layout: .init(title: .init(title: detail.name), detail: .init(detail: "Индивидуальное предложение по ТО от ТТС")), selected: { [weak self] in
                guard let `self` = self, let service = self.response?.0 else { return }
                self.delegate?.orderTechServiceDetailSelectViewController(self, didSelectService: service, detail: detail)
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
    
    // MARK: - Managing the Data
    
    private var response: (OrderTechServiceGetListResponse.Service, OrderTechServiceGetDetailResponse)? {
        didSet {
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
}
