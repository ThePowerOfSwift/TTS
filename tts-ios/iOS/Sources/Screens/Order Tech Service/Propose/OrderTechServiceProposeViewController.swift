//
//  OrderTechServiceProposeViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

protocol OrderTechServiceProposeViewControllerDelegate: class {
    func orderTechServiceProposeViewController(_ viewController: OrderTechServiceProposeViewController, didTapServiceListButtonWithList list: OrderTechServiceGetListResponse)
    func orderTechServiceProposeViewController(_ viewController: OrderTechServiceProposeViewController, didCompleteWithService service: OrderTechServiceGetListResponse.Service, details: OrderTechServiceGetDetailResponse)
    func orderTechServiceProposeViewControllerDidClose(_ viewController: OrderTechServiceProposeViewController)
}

final class OrderTechServiceProposeViewController: UIViewController, ListAdapterDataSource, ErrorPresenting {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var submitButton: SubmitButton!
    
    weak var delegate: OrderTechServiceProposeViewControllerDelegate?
    private let interactor: OrderTechServiceProposeInteractor
    private var adapter: ListAdapter!
    
    init(interactor: OrderTechServiceProposeInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = "Выбор номера ТО"
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
        
        interactor.observeData { [weak self] in
            self?.response = ($0, $1)
        }
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
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        
        result.append(ListBasicItem(layout: .init(title: .init(title: "Исходя из вашего пробега или временного интервала (что наступит раньше), мы считаем, что у Вас:"), separatorStyle: .none, isChevronHidden: true), selected: nil))
        
        if let service = service {
            result.append(OrderTechServiceProposeItem(title: service.title, subtitle: service.date, rightDetailTitle: service.mileage))
        }
        
        result.append(ListBasicItem(layout: .init(title: .init(title: "Хочу выбрать номер ТО сам")), selected: { [weak self] in
            guard let `self` = self, let list = self.response?.0 else { return }
            self.delegate?.orderTechServiceProposeViewController(self, didTapServiceListButtonWithList: list)
        }))
        
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ListBasicItem {
            return ListBasicSectionController()
        } else if object is OrderTechServiceProposeItem {
            return OrderTechServiceProposeSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - Managing Data
    
    private var response: (OrderTechServiceGetListResponse, [PhoneNumber])? {
        didSet {
            service = response?.0.toRecommendService
        }
    }
    
    var service: OrderTechServiceGetListResponse.Service? {
        didSet {
            adapter.performUpdates(animated: false, completion: nil)
        }
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
    
    // MARK: - Submitting
    
    @IBAction
    private func submitButtonTapped() {
        guard let service = service else { return }
        sendData(service: service)
    }
    
    // MARK: - Data Sending
    
    private func sendData(service: OrderTechServiceGetListResponse.Service) {
        setIsLoading(true)
        interactor.getDetail(techServiceUid: service.uid) { [weak self] in
            self?.setIsLoading(false)
            switch $0 {
            case .success(let response):
                guard let `self` = self else { return }
                self.delegate?.orderTechServiceProposeViewController(self, didCompleteWithService: service, details: response)
            case .failure(let error):
                if let phoneNumber = self?.response?.1.first {
                    self?.showErrorWithCallbackAction(phoneNumber)
                } else {
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showErrorWithCallbackAction(_ phoneNumber: PhoneNumber) {
        let viewController = UIAlertController(title: "Запись через приложение не может быть осуществлена", message: "Перезвоните нам, пожалуйста.", preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Перезвонить", style: .default, handler: { _ in
            CallAction.call(phone: phoneNumber, completion: nil)
        }))
        viewController.addAction(UIAlertAction(title: "Вернуться в гараж", style: .default, handler: { [weak self] _ in
            self?.showTechServiceOrderCancel()
        }))
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
    private func showTechServiceOrderCancel() {
        showError(title: "Запись не была осуществлена", message: nil, animated: IsAnimationAllowed(), close: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.orderTechServiceProposeViewControllerDidClose(self)
            }, completion: nil)
    }
    
}
