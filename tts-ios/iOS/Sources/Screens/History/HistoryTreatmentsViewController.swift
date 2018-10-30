//
//  HistoryTreatmentsViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import XLPagerTabStrip

final class HistoryTreatmentsViewController: UIViewController, ListAdapterDataSource, IndicatorInfoProvider {

    private let auto: UserAuto
    private let interactor: HistoryTreatmentsInteractor

    private var collectionView: UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    private var adapter: ListAdapter!
    
    init(auto: UserAuto, interactor: HistoryTreatmentsInteractor) {
        self.auto = auto
        self.interactor = interactor
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
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        interactor.observeTreatments(autoId: auto.id) { [weak self] in
            self?.treatments = $0
        }
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearSelectionWhenInteractionEnds(for: collectionView, animated: IsAnimationAllowed())
    }
    
    // MARK: - Setting Treatments
    
    private var treatments: [Treatment]? {
        didSet {
            adapter.reloadData(completion: nil)
        }
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return (treatments ?? []).map { treatment in HistoryTreatmentItem(treatment: treatment, didSelectItem: { [weak self] in
            self?.didSelectTreatment(treatment)
        })}
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is HistoryTreatmentItem {
            return HistoryTreatmentSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        if isLoading {
            let spinner = UIActivityIndicatorView(style: .white)
            spinner.startAnimating()
            return spinner
        } else {
            return HistoryEmptyViewController(auto: auto).view
        }
    }
    
    // MARK: - Providing Indicator Info
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: auto.brand)
    }
    
    // MARK: - Selecting Items
    
    private func didSelectTreatment(_ treatment: Treatment) {
        let viewController = HistoryDetailsViewController(auto: auto, treatment: treatment, interactor: interactor.createHistoryDetailsInteractor())
        navigationController?.show(viewController, sender: nil)
    }
    
    private var isLoading = false
    func setIsLoading(_ loading: Bool) {
        guard isLoading != loading else { return }
        isLoading = loading
        
        if loading {
            adapter.reloadData(completion: nil)
        } else {
            adapter.reloadData(completion: nil)
        }
    }
    
}
