//
//  CallAction.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import RxSwift

final class CallAction {
    
    enum Result {
        case completed
        case cancelled
        case failed(Error)
    }
    
    static let hotLinePhoneNumber = try! PhoneNumber(free: "88007004926") // swiftlint:disable:this force_try
    
    private weak var presentingViewController: UIViewController?
    private let user: UserInfoService
    private let disposeBag = DisposeBag()
    
    init(presentingViewController: UIViewController, user: UserInfoService) {
        self.presentingViewController = presentingViewController
        self.user = user
    }
    
    func call(phone: PhoneNumber, title: String, completion: ((Result) -> Void)?) {
        let viewController = UIAlertController(title: title, message: PhoneNumberFormatter().string(from: phone), preferredStyle: .actionSheet)
        viewController.addAction(UIAlertAction(title: "Позвонить", style: .default, handler: { _ in
            CallAction.call(phone: phone, completion: completion)
        }))
        viewController.addAction(UIAlertAction(title: "Перезвоните мне", style: .default, handler: { [weak self] _ in
            self?.presentCallbackViewController(completion: completion)
        }))
        viewController.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: { _ in
            completion?(.cancelled)
        }))
        presentingViewController?.present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
    // MARK: - Call
    
    static func call(phone: PhoneNumber, completion: ((Result) -> Void)?) {
        let url = URL(string: "tel:\(phone.rawValue)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        completion?(.completed)
    }
    
    // MARK: - Requesting Callback
    
    private func presentCallbackViewController(completion: ((Result) -> Void)?) {
        // spinner view controller
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.autoresizingMask = .flexibleMargins
        spinner.startAnimating()
        let spinnerViewController = UIViewController()
        spinner.center = spinnerViewController.view.bounds.center
        spinnerViewController.view.addSubview(spinner)
        spinnerViewController.preferredContentSize = CGSize(width: presentingViewController?.view.bounds.width ?? 0, height: 100)
        
        let viewController = ActionSheetController(title: nil, message: nil)
        viewController.contentViewController = spinnerViewController
        
        viewController.addAction(ActionSheetAction(title: "Закрыть", style: .cancel, handler: { _ in
            completion?(.cancelled)
        }))
        viewController.preferredAction = viewController.actions.first
        presentingViewController?.present(viewController, animated: IsAnimationAllowed(), completion: nil)
        
        callback {
            if let error = $0 {
                viewController.showError(error, animated: IsAnimationAllowed(), close: { [weak viewController] in
                    viewController?.dismiss(animated: IsAnimationAllowed(), completion: {
                        completion?(.failed(error))
                    })
                }, completion: nil)
            } else {
                viewController.setImage(#imageLiteral(resourceName: "action_sheet_icn_ok"))
                viewController.title = "Спасибо за обращение!"
                viewController.message = "В ближайшее время с вами\nсвяжется оператор"
                viewController.contentViewController = nil
                viewController.actions.last?.handler = { _ in
                    completion?(.completed)
                }
            }
        }
    }
    
    func callback(completion: @escaping (Error?) -> Void) {
        user.callback()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            }).disposed(by: disposeBag)
    }
    
}
