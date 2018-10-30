//
//  GarageArchiveViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 12/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit

final class GarageArchiveViewController: CollectionViewController, ErrorPresenting {

    let interactor: GarageArchiveInteractor
    
    init(interactor: GarageArchiveInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Архив авто"

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
            self?.adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                self?.presentRestoreViewController(auto: $0)
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
    
    // MARK: - Removing From Archive
    
    private func removeFromArchive(vin: String) {
        interactor.removeFromArchive(vin: vin, completion: { [weak self] in
            if let error = $0 {
                self?.showError(error)
            }
        })
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
    
    // MARK: - Restoring User Auto From Archive
    
    private func presentRestoreViewController(auto: UserAuto) {
        let viewController = UIAlertController(title: "Восстановить авто?", message: auto.brand, preferredStyle: .actionSheet)
        viewController.addAction(UIAlertAction(title: "Восстановить", style: .default, handler: { [weak self] _ in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
            self?.removeFromArchive(vin: auto.vin)
        }))
        viewController.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: { [weak self] _ in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
        }))
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
}
