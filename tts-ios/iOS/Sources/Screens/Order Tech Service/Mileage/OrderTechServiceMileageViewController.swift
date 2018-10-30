//
//  OrderTechServiceMileageViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

protocol OrderTechServiceMileageViewControllerDelegate: class {
    func orderTechServiceMileageViewController(_ viewController: OrderTechServiceMileageViewController, didCompleteWithList list: OrderTechServiceGetListResponse)
}

final class OrderTechServiceMileageViewController: UIViewController, ListAdapterDataSource, ErrorPresenting {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var submitButton: SubmitButton!
    
    weak var delegate: OrderTechServiceMileageViewControllerDelegate?
    private let interactor: OrderTechServiceMileageInteractor
    private var adapter: ListAdapter!
    private var behavior: KeepSubmitButtonAlwaysOnTopOfKeyboardBehavior!
    private var textField: UITextField?
    
    init(interactor: OrderTechServiceMileageInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = "Определить номер ТО"
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
        
        behavior = KeepSubmitButtonAlwaysOnTopOfKeyboardBehavior(submitButton: submitButton)
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearSelectionWhenInteractionEnds(for: collectionView, animated: IsAnimationAllowed())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField?.becomeFirstResponder()
        collectionView.flashScrollIndicators()
    }
    
    // MARK: - Extending the View's Safe Area

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        behavior.layoutAtBottomGuide()
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adapter.performUpdates(animated: false, completion: nil)
    }
    
    // MARK: - List Adapter
    
    private var noMileageCell: ListButtonCell?
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        
        result.append(ListTextFieldItem(id: "mileage") { [weak self] in
            $0.attributedTitle = "Введите ориентировочный пробег".with(StringAttributes {
                $0.font = .systemFont(ofSize: 15)
                $0.foregroundColor = UIColor(r: 109, g: 121, b: 135)
            })
            $0.separatorInset = UIEdgeInsets(horizontal: 16, vertical: 0)
            $0.textField.attributedPlaceholder = "3867".with(StringAttributes {
                $0.font = .systemFont(ofSize: 24)
                $0.foregroundColor = UIColor(r: 43, g: 49, b: 70)
            })
            $0.textField.defaultTextAttributes = StringAttributes({
                $0.font = .systemFont(ofSize: 24)
                $0.foregroundColor = .white
            })
            
            $0.textField.keyboardType = .numberPad
            $0.textField.keyboardAppearance = .dark
            
            let label = UILabel()
            label.attributedText = "км".with(StringAttributes {
                $0.font = .systemFont(ofSize: 15)
                $0.foregroundColor = UIColor(r: 93, g: 105, b: 118)
            })
            label.sizeToFit()
            $0.textField.rightView = label
            $0.textField.rightViewMode = .always
            
            $0.textFieldFormatter = TextFieldFormatter(textField: $0.textField, mask: MileageMask())
            
            $0.shouldReturn = {
                self?.submitButtonTapped()
                return true
            }
            
            self?.textField = $0.textField
            self?.textField?.becomeFirstResponder()
        })
        
        result.append(ListButtonItem(id: "no_mileage",
                                     config: { [weak self] in
                                        $0.textLabel.attributedText = "Не знаю пробег".with(StringAttributes {
                                            $0.font = .systemFont(ofSize: 15)
                                            $0.foregroundColor = .red
                                            $0.alignment = .center
                                        })
                                        $0.accessoryView.isHidden = true
                                        $0.separatorStyle = .none
                                        $0.selectionStyle = .gray
                                        self?.noMileageCell = $0
        },
                                     select: { [weak self] in
                                        self?.noMileageButtonTapped()
        }))
        
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ListTextFieldItem {
            return ListTextFieldSectionController()
        } else if object is ListButtonItem {
            return ListButtonSectionController()
        } else {
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - Loading Indication
    
    private func setIsLoading(_ loading: Bool, isNoMileageButtonTapped: Bool) {
        if loading {
            submitButton.isEnabled = false
            textField?.isEnabled = false
            if isNoMileageButtonTapped {
                submitButton.isEnabled = false
                noMileageCell?.spinner.startAnimating()
            } else {
                submitButton.startAnimating()
                noMileageCell?.isUserInteractionEnabled = false
            }
        } else {
            submitButton.isEnabled = true
            textField?.isEnabled = true
            if isNoMileageButtonTapped {
                submitButton.isEnabled = true
                noMileageCell?.spinner.stopAnimating()
            } else {
                submitButton.stopAnimating()
                noMileageCell?.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func noMileageButtonTapped() {
        sendData(mileage: nil)
    }
    
    @IBAction
    private func submitButtonTapped() {
        guard let text = textField?.text, let number = NumberFormatter().number(from: text) else { return }
        sendData(mileage: number.intValue)
    }
    
    private func sendData(mileage: Int?) {
        let isNoMileageButtonTapped = mileage == nil
        setIsLoading(true, isNoMileageButtonTapped: isNoMileageButtonTapped)
        interactor.getList(mileage: mileage) { [weak self] in
            self?.setIsLoading(false, isNoMileageButtonTapped: isNoMileageButtonTapped)
            switch $0 {
            case .failure(let error):
                self?.showError(error, animated: IsAnimationAllowed(), close: {
                    self?.collectionView.deselectAll(animated: IsAnimationAllowed())
                    self?.textField?.becomeFirstResponder()
                })
            case .success(let response):
                guard let `self` = self else { return }
                self.delegate?.orderTechServiceMileageViewController(self, didCompleteWithList: response)
            }
        }
    }
    
}
