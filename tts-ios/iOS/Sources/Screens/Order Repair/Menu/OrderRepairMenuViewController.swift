//
//  OrderRepairMenuViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 21/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit
import AlamofireImage

protocol OrderRepairMenuViewControllerDelegate: class {
    func orderRepairMenuViewControllerDidClose(_ viewController: OrderRepairMenuViewController)
    func orderRepairMenuViewController(_ viewController: OrderRepairMenuViewController, didSelectRepairPoint repairPoint: RepairPoint?)
    func orderRepairMenuViewController(_ viewController: OrderRepairMenuViewController, didSelectComment comment: String?)
    func orderRepairMenuViewController(_ viewController: OrderRepairMenuViewController, didCompleteWithResponse response: MessageResponse)
}

final class OrderRepairMenuViewController: UIViewController, ListAdapterDataSource, ErrorPresenting {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var submitButton: SubmitButton!
    @IBOutlet private var submitButtonHeight: NSLayoutConstraint!
    
    weak var delegate: OrderRepairMenuViewControllerDelegate?
    private let interactor: OrderRepairMenuInteractor
    private var adapter: ListAdapter!
    
    init(interactor: OrderRepairMenuInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = "Кузовной ремонт"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_close"), style: .plain) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.orderRepairMenuViewControllerDidClose(self)
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
        
        let bottomInset = bottomLayoutGuide.length
        submitButtonHeight.constant = 52 + bottomInset
        submitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        adapter.performUpdates(animated: false, completion: nil )
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        
        let minHeight: CGFloat = 64
        
        let image = repairPoint.flatMap { ListBasicLayout.Image.url($0.image, filter: AspectScaledToFillSizeCircleFilter(size: CGSize(width: 40, height: 40)))}
        result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: image, title: "Сервисный центр", detail: repairPoint?.name), minHeight: minHeight) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.orderRepairMenuViewController(self, didSelectRepairPoint: self.repairPoint)
        })
        
        result.append(ListBasicItem(layout: .init(parameterLayoutWithImage: nil, title: "Комментарий", detail: comment), minHeight: minHeight, selected: { [unowned self] in
            if self.repairPoint != nil {
                self.delegate?.orderRepairMenuViewController(self, didSelectComment: self.comment)
            } else {
                self.presentCommentSelectionError()
            }
        }))
        
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ListBasicItem {
            return ListBasicSectionController()
        } else if object is ListTextFieldItem {
            return ListTextFieldSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - Loading Indication
    
    private func setIsLoading(_ loading: Bool) {
        if loading {
            submitButton.isEnabled = false
            submitButton.startAnimating()
        } else {
            submitButton.isEnabled = true
            submitButton.stopAnimating()
        }
    }
    
    // MARK: - Actions
    
    @IBAction
    private func submitButtonTapped() {
        guard let ukrUid = repairPoint?.uid else {
            presentServiceCenterSelectionError()
            return
        }
        sendData(ukrUid: ukrUid, comment: comment)
    }
    
    // MARK: - Managing the Data
    
    private var repairPoint: RepairPoint?
    private var comment: String?

    func setRepairPoint(_ value: RepairPoint?) {
        repairPoint = value
        adapter.performUpdates(animated: false, completion: nil)
    }
    
    func setComment(_ value: String?) {
        comment = value?.trimmingCharacters(in: .whitespaces)
        adapter.performUpdates(animated: false, completion: nil)
    }
    
    private func sendData(ukrUid: String, comment: String?) {
        setIsLoading(true)
        interactor.sendData(ukrUid: ukrUid, comment: comment) { [weak self] in
            self?.setIsLoading(false)
            switch $0 {
            case .failure(let error):
                self?.showError(error, animated: IsAnimationAllowed())
            case .success(let response):
                guard let `self` = self else { return }
                self.delegate?.orderRepairMenuViewController(self, didCompleteWithResponse: response)
            }
        }
    }
    
    // MARK: - Presenting Errors

    private func presentServiceCenterSelectionError() {
        showError(title: "Чтобы записаться на кузовной ремонт, нужно сначала выбрать сервисный центр", message: nil, animated: IsAnimationAllowed(), close: { [weak self] in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
            }, completion: nil)
    }
    
    private func presentCommentSelectionError() {
        showError(title: "Чтобы ввести комментарий, нужно сначала выбрать сервисный центр", message: nil, animated: IsAnimationAllowed(), close: { [weak self] in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
            }, completion: nil)
    }
    
}
