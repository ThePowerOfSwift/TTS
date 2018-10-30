//
//  OrderTechServiceVariantsViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

protocol OrderTechServiceVariantsViewControllerDelegate: class {
    func orderTechServiceVariantsViewController(_ viewController: OrderTechServiceVariantsViewController, didSelectVariant variant: OrderTechServiceGetVariantsResponse.Variant, auto: UserAuto, serviceCenter: ServiceCenter, selection: OrderTechServiceSelection)
}

final class OrderTechServiceVariantsViewController: UIViewController, ListAdapterDataSource, ErrorPresenting {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var nextButton: SubmitButton!
    @IBOutlet private var submitButton: SubmitButton!
    @IBOutlet private var submitButtonHeight: NSLayoutConstraint!
    
    weak var delegate: OrderTechServiceVariantsViewControllerDelegate?
    private let interactor: OrderTechServiceVariantsInteractor
    private var adapter: ListAdapter!
    private var selectedIndex: Int?
    private var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    init(interactor: OrderTechServiceVariantsInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_global_date"), style: .plain, block: { [weak self] in
            self?.presentDatePickerViewController {
                var calendar = Calendar.autoupdatingCurrent
                calendar.locale = Locale.ru_RU
                if let date = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: $0) {
                    self?.fetchData(date: date)
                }
            }
        })
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.ru_RU
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM y")

        interactor.observeData { [weak self] in
            let date = $0.variants?.last?.1
            self?.title = date.flatMap { dateFormatter.string(from: $0) }
            
            self?.data = $0
        }
        
        setNextButtonHidden(false)
        updateSubmitButtonState()
        
        fetchData(date: interactor.initialDate())
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
    
    // MARK: - Extending the View's Safe Area
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        updateScrollViewBottomInset()
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateScrollViewBottomInset()
    }
    
    private func updateScrollViewBottomInset() {
        if #available(iOS 11.0, *) {
            submitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: collectionView.safeAreaInsets.bottom, right: 0)
            submitButtonHeight.constant = 52 + collectionView.safeAreaInsets.bottom
        } else {
            submitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            submitButtonHeight.constant = 52 + bottomLayoutGuide.length
        }
        
        var insetBottom = submitButton.bounds.height
        if nextButton.isHidden {
            insetBottom += submitButton.frame.minY - nextButton.frame.maxY
        } else {
            insetBottom += submitButton.frame.minY - nextButton.frame.minY
        }
        
        if #available(iOS 11.0, *) {
            collectionView.contentInset.bottom = insetBottom - collectionView.safeAreaInsets.bottom
        } else {
            collectionView.contentInset.bottom = insetBottom
        }
        collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
    }
    
    // MARK: - List Adapter
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []

        if let data = data {
            let variants = data.variants
            
            if (variants?.count ?? 0) > 0 {
                result.append(ListBasicItem(layout: .init(title: .init(string: "Ваш выбор", font: .systemFont(ofSize: 15), textColor: UIColor(r: 112, g: 124, b: 137)), separatorStyle: .none, isChevronHidden: true), selected: nil))
            }
            
            for (index, (variant, _)) in (variants ?? []).enumerated() {
                let isSelected = index == selectedIndex
                result.append(OrderTechServiceVariantItem(index: index, variant: variant, isSelected: isSelected, select: { [weak self] in
                    self?.selectedIndex = index
                    self?.adapter.performUpdates(animated: false, completion: nil)
                    self?.updateSubmitButtonState()
                }))
            }
        }
        
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ListBasicItem {
            return ListBasicSectionController()
        } else if object is OrderTechServiceVariantItem {
            return OrderTechServiceVariantSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - Managing the Data
    
    private var data: OrderTechServiceVariantDTO? {
        didSet {
            let numberOfVariants = data?.variants?.count ?? 0
            if selectedIndex == nil, numberOfVariants > 0 {
                selectedIndex = 0
                updateSubmitButtonState()
            }
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    private func fetchData(date: Date) {
        setIsLoading(true)
        interactor.getVariants(date: date) { [weak self] in
            self?.setIsLoading(false)
            switch $0 {
            case .success(let shouldResetVariants):
                if shouldResetVariants {
                    self?.selectedIndex = nil
                }
                self?.setNextButtonHidden(false)
            case .failure(let error):
                if case ResponseMapperError.mappingFailed(let underlying) = error, case ResponseResultError.invalidErrorCode(let code, _) = underlying {
                    self?.setNextButtonHidden(code == 27)
                }
                self?.showError(error)
            }
        }
    }
    
    // MARK: - Handling Next Button
    
    @IBAction
    private func nextButtonTapped() {
        guard let date = data?.variants?.last?.1 else { return }
        fetchData(date: date)
    }
    
    private func setNextButtonHidden(_ hidden: Bool) {
        nextButton.isHidden = hidden
        view.setNeedsLayout()
    }
    
    // MARK: - Handling Submit Button
    
    @IBAction
    private func submitButtonTapped() {
        guard let selectedIndex = selectedIndex, let data = data, let variant = data.variants?[selectedIndex].0 else { return }
        delegate?.orderTechServiceVariantsViewController(self, didSelectVariant: variant, auto: data.auto, serviceCenter: data.serviceCenter, selection: data.selection)
    }
    
    private func updateSubmitButtonState() {
        submitButton.isEnabled = selectedIndex != nil
    }
    
    // MARK: - Indicating Loading
    
    private func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            spinner.frame = view.bounds
            spinner.autoresizingMask = .flexibleDimensions
            spinner.backgroundColor = UIColor(white: 0, alpha: 0.1)
            spinner.startAnimating()
            view.addSubview(spinner)
        } else {
            spinner.removeFromSuperview()
            spinner.stopAnimating()
        }
    }
    
    // MARK: - Managing the Responder Chain
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Presenting Date Picker
    
    private func presentDatePickerViewController(completed: @escaping (Date) -> Void) {
        let viewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let initialDate = interactor.initialDate()
        var date = data?.variants?.last?.1 ?? Date()
        
        let contentViewController = UIViewController()
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = initialDate
        datePicker.date = date
        datePicker.addAction(forControlEvents: .valueChanged, {
            date = $0.date
        })
        datePicker.sizeToFit()
        contentViewController.view = datePicker
        viewController.setContentViewController(contentViewController, preferredContentHeight: datePicker.bounds.height)
        
        viewController.addAction(UIAlertAction(title: "Выбрать", style: .cancel, handler: { _ in
            completed(date)
        }))
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
}
