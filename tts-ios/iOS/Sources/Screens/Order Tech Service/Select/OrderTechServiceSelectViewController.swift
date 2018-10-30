//
//  OrderTechServiceSelectViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 22/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

protocol OrderTechServiceSelectViewControllerDelegate: class {
    
    func orderTechServiceSelectViewControllerDidClose(_ viewController: OrderTechServiceSelectViewController)
    func orderTechServiceSelectViewControllerDidSelectTechService(_ viewController: OrderTechServiceSelectViewController)
    func orderTechServiceSelectViewController(_ viewController: OrderTechServiceSelectViewController, didSelectStandardOperationsWithOtherWork otherWork: String?)
    func orderTechServiceSelectViewController(_ viewController: OrderTechServiceSelectViewController, didConfirmOrderTechServiceSelection selection: OrderTechServiceSelection)
    
}

final class OrderTechServiceSelectViewController: UIViewController, ListAdapterDataSource {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var submitButton: SubmitButton!
    
    weak var delegate: OrderTechServiceSelectViewControllerDelegate?
    private var adapter: ListAdapter!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Запись в СЦ"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_close"), style: .plain) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.orderTechServiceSelectViewControllerDidClose(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        updateSubmitButtonVisibility()
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
        
        adapter.performUpdates(animated: false, completion: nil)
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        
        let text = orderTechService?.0.name ?? "Запись ТО"
        result.append(ListBasicItem(layout: .init(image: .image(#imageLiteral(resourceName: "tech_service")), title: .init(title: text, font: .boldSystemFont(ofSize: 17))), selected: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.orderTechServiceSelectViewControllerDidSelectTechService(self)
        }))
        
        let title = otherWork.flatMap { $0.count > 0 ? $0 : nil } ?? "Запись на Стандартные операции"
        result.append(ListBasicItem(layout: .init(image: .image(#imageLiteral(resourceName: "tech_service_regular")), title: .init(title: title, font: .systemFont(ofSize: 15))), selected: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.orderTechServiceSelectViewController(self, didSelectStandardOperationsWithOtherWork: self.otherWork)
        }))
        
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
    
    // MARK: - Detail Setting
    
    private var orderTechService: (OrderTechServiceGetListResponse.Service, OrderTechServiceGetDetailResponse.Detail)?
    func setOrderTechService(service: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail) {
        orderTechService = (service, detail)
        updateSubmitButtonVisibility()
        adapter.performUpdates(animated: false, completion: nil)
    }
    
    var otherWork: String? {
        didSet {
            updateSubmitButtonVisibility()
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    // MARK: - Handling Submit Button
    
    private func updateSubmitButtonVisibility() {
        let otheWorkNumberOfCharacters = otherWork?.count ?? 0
        submitButton.isHidden = orderTechService == nil && otheWorkNumberOfCharacters == 0
    }
    
    @IBAction
    private func submitButtonTapped() {
        let selection: OrderTechServiceSelection
        if let orderTechService = orderTechService {
            selection = .techService(orderTechService.0, orderTechService.1, otherWork)
        } else if let otherWork = otherWork {
            selection = .otherWork(otherWork)
        } else {
            return
        }
        
        delegate?.orderTechServiceSelectViewController(self, didConfirmOrderTechServiceSelection: selection)
    }

}
