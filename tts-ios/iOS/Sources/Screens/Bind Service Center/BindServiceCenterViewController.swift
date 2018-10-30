//
//  BindServiceCenterViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit

final class BindServiceCenterViewController: CollectionViewController, ErrorPresenting {

    private let uid: String
    private let interactor: BindServiceCenterInteractor
    private let complete: () -> Void
    
    init(uid: String, interactor: BindServiceCenterInteractor, complete: @escaping () -> Void, cancel: @escaping () -> Void) {
        self.uid = uid
        self.interactor = interactor
        self.complete = complete
        super.init(nibName: nil, bundle: nil)
        title = "Выбор авто"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_close"), style: .plain) {
            cancel()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        
        let topContentInset: CGFloat
        if #available(iOS 11, *) {
            topContentInset = 0
        } else {
            topContentInset = topLayoutGuide.length
        }
        let layout = ListCollectionViewLayout(stickyHeaders: false, topContentInset: topContentInset, stretchToEdge: false)
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        collectionView.refreshControl = UIRefreshControl { [weak self] in
            self?.reloadData()
        }
        
        interactor.observeData { [weak self] in
            self?.autos = $0
            self?.adapter.reloadData(completion: nil)
        }
        reloadData()
    }
    
    // MARK: - Managing the Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - List Adapter
    
    private var autos: [UserAuto]?
    
    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if let autos = autos {
            return autos.map {auto in UserAutoTileItem(auto: auto, didSelect: { [weak self] in
                self?.bindUserAuto(auto: $0)
            })}
        } else {
            return []
        }
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is UserAutoTileItem {
            return UserAutoTileSectionController()
        } else {
            fatalError()
        }
    }
    
    // MARK: - Refreshing
    
    private func reloadData() {
        interactor.reloadData { [weak self] in
            self?.collectionView.refreshControl?.endRefreshing()
            if let error = $0 {
                self?.showError(error)
            }
        }
    }
    
    // MARK: - Binding Service Center
    
    private func bindUserAuto(auto: UserAuto) {
        if auto.serviceCenter == nil {
            sendBindUserAutoRequest(auto: auto)
        } else {
            BindServiceCenterViewController.presentPromptViewController(presentingViewController: self, proceed: { [weak self] in
                self?.sendBindUserAutoRequest(auto: auto)
                self?.collectionView.deselectAll(animated: IsAnimationAllowed())
            }, cancel: { [weak self] in
                self?.collectionView.deselectAll(animated: IsAnimationAllowed())
            })
        }
    }
    
    static func presentPromptViewController(presentingViewController: UIViewController, proceed: @escaping () -> Void, cancel: (() -> Void)?) {
        let viewController = ActionSheetController(title: "Вы действительно хотите сменить сервисный центр?", message: "Ваш автомобиль будет отвязан от предыдущего СЦ")
        viewController.setImage(#imageLiteral(resourceName: "icn_exclamation"))
        viewController.addAction(ActionSheetAction(title: "Нет", style: .cancel, handler: { _ in
            cancel?()
        }))
        viewController.addAction(ActionSheetAction(title: "Да", style: .default, handler: { _ in
            proceed()
        }))
        presentingViewController.present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
    private func sendBindUserAutoRequest(auto: UserAuto) {
        interactor.bindingServiceCenter(uid: uid, vin: auto.vin) { [weak self] in
            if let error = $0 {
                self?.showError(error)
            } else {
                self?.complete()
            }
        }
    }
    
}
