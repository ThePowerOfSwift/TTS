//
//  ProfileViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit

protocol ProfileViewControllerDelegate: class {
    func profileViewControllerDidTapBonusButton(_ viewController: ProfileViewController)
    func profileViewControllerDidTapAddCarCell(_ viewController: ProfileViewController, close: (() -> Void)?)
    func profileViewControllerDidTapArchiveCell(_ viewController: ProfileViewController)
    func profileViewControllerDidTapAboutCell(_ viewController: ProfileViewController)
}

final class ProfileViewController: CollectionViewController, ErrorPresenting {

    weak var delegate: ProfileViewControllerDelegate?

    private let interactor: ProfileInteractor
    private let loggedOut: () -> Void
    
    init(interactor: ProfileInteractor, loggedOut: @escaping () -> Void) {
        self.interactor = interactor
        self.loggedOut = loggedOut
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        
        interactor.observeUserInfo { [weak self] in
            self?.data = $0
        }
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        interactor.reloadUserInfo()
    }
    
    // MARK: - Managing the Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - List Adapter
    
    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let userInfo = data?.0
        let isPushAuthorized = data?.1 ?? false
        
        var pushStatus = userInfo?.pushStatus ?? .disabled
        if !isPushAuthorized {
            pushStatus = .disabled
        }
        
        let labelsContainerViewLeadingSpace = ListBasicLayout.Space.custom(52)
        
        return [
            ProfileUserInfoItem(name: userInfo?.name, bonuses: userInfo?.bonuses, phone: userInfo?.phone, bonusButtonTapped: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.profileViewControllerDidTapBonusButton(self)
            }),
            ListSwitchItem(title: "Push-уведомления", image: #imageLiteral(resourceName: "icn_notifications"), isOn: pushStatus == .enabled, separatorInset: .zero, shouldChangeSwitchControlValue: { [weak self] in
                guard let `self` = self else { return false }
                return self.shouldSetPushNotificationsEnabled($0)
            }),
            ListHeaderItem(id: "0"),
            ListBasicItem(layout: .init(image: .image(#imageLiteral(resourceName: "icn_add_car")), title: .init(title: "Добавить авто"), labelsContainerViewLeadingSpace: labelsContainerViewLeadingSpace), selected: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.profileViewControllerDidTapAddCarCell(self, close: { [weak self] in
                    self?.collectionView.deselectAll(animated: IsAnimationAllowed())
                })
            }),
            ListBasicItem(layout: .init(image: .image(#imageLiteral(resourceName: "icn_archive")), title: .init(title: "Архив авто"), labelsContainerViewLeadingSpace: labelsContainerViewLeadingSpace), selected: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.profileViewControllerDidTapArchiveCell(self)
            }),
            ListBasicItem(layout: .init(image: .image(#imageLiteral(resourceName: "icn_about")), title: .init(title: "Информация о приложении"), labelsContainerViewLeadingSpace: labelsContainerViewLeadingSpace, separatorStyle: .inset(.custom(.zero))), selected: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.profileViewControllerDidTapAboutCell(self)
            }),
            ListHeaderItem(id: "1"),
            ListBasicItem(layout: .init(image: .image(#imageLiteral(resourceName: "icn_logout")), title: .init(title: "Выйти", textColor: UIColor(r: 241, g: 52, b: 52)), labelsContainerViewLeadingSpace: labelsContainerViewLeadingSpace, separatorStyle: .inset(.custom(.zero)), isChevronHidden: true), selected: { [weak self] in
                self?.logoutCellTapped()
            }),
            ListHeaderItem(id: "2", separatorStyle: .none)
        ]
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ProfileUserInfoItem {
            return ProfileUserInfoSectionController()
        } else if object is ListSwitchItem {
            return ListSwitchSectionController()
        } else if object is ListHeaderItem {
            return ListHeaderSectionController()
        } else if object is ListBasicItem {
            return ListBasicSectionController()
        } else {
            fatalError()
        }
    }
    
    // MARK: - Data
    
    private var data: (UserInfo?, Bool)? {
        didSet {
            adapter.performUpdates(animated: IsAnimationAllowed(), completion: nil)
        }
    }
    
    // MARK: - Logging Out
    
    private func logoutCellTapped() {
        presentLogoutPrompt()
    }
    
    private func presentLogoutPrompt() {
        
        let viewController = UIAlertController(title: nil, message: "После выхода вам придется повторно ввести номер телефона и cмс-код", preferredStyle: .actionSheet)
        viewController.attributedTitle = "Выйти из профиля?".with(StringAttributes {
            $0.font = .systemFont(ofSize: 17, weight: .bold)
            $0.foregroundColor = UIColor(white: 45 / 255.0, alpha: 1)
        })
        viewController.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { [weak self] _ in
            self?.interactor.logout(completion: {
                if let error = $0 {
                    self?.showError(error)
                } else {
                    self?.loggedOut()
                }
            })
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
        }))
        viewController.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: { [weak self] _ in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
        }))
        viewController.preferredAction = viewController.actions.last
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
    // MARK: - Push Notifications
    
    private func shouldSetPushNotificationsEnabled(_ enabled: Bool) -> Bool {
        let isPushAuthorized = data?.1 ?? false
        guard isPushAuthorized else {
            presentPushNotificationsRequiresAuthorizationMessage()
            return false
        }
        
        interactor.setPushNotificationsEnabled(enabled) { [weak self] in
            if let error = $0.error {
                self?.showError(error)
            }
        }
        
        return true
    }
    
    private func presentPushNotificationsRequiresAuthorizationMessage() {
        let viewController = UIAlertController(title: "Разрешите уведомления в настройках", message: "С помощью уведомления мы напомним о визите на ТО", preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        viewController.addAction(UIAlertAction(title: "Разрешить", style: .default, handler: { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
}
