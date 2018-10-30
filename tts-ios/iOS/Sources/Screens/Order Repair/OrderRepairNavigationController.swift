//
//  OrderRepairNavigationController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 21/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class OrderRepairNavigationController: NavigationController {

    private var interactor: OrderRepairInteractor!
    private var close: ((OrderRepairNavigationController) -> Void)?
    
    init(interactor: OrderRepairInteractor, close: ((OrderRepairNavigationController) -> Void)?) {
        super.init(style: .barTintColor(UIColor(r: 19, g: 25, b: 43)), tintColor: .white, barStyle: .black)
        self.interactor = interactor
        self.close = close
        
        let viewController = OrderRepairMenuViewController(interactor: interactor.createOrderRepairMenuInteractor())
        viewController.delegate = self
        viewControllers = [viewController]
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OrderRepairNavigationController: OrderRepairMenuViewControllerDelegate {
    
    func orderRepairMenuViewControllerDidClose(_ viewController: OrderRepairMenuViewController) {
        close?(self)
    }
    
    func orderRepairMenuViewController(_ viewController: OrderRepairMenuViewController, didSelectRepairPoint repairPoint: RepairPoint?) {
        presentServiceCenterCityPickerViewController(repairPoint: repairPoint)
    }
    
    func orderRepairMenuViewController(_ viewController: OrderRepairMenuViewController, didSelectComment comment: String?) {
        presentCommentViewController(comment: comment)
    }
    
    func orderRepairMenuViewController(_ viewController: OrderRepairMenuViewController, didCompleteWithResponse response: MessageResponse) {
        presentRepairOrderCompletionMessage(response: response, close: { [weak self] in
            guard let `self` = self else { return }
            self.close?(self)
        })
    }
    
    private func presentServiceCenterCityPickerViewController(repairPoint: RepairPoint?) {
        let interactor = self.interactor.createCitiesInteractor()
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = $1.name
        }, select: { [weak self] in
            self?.presentServiceCenterPickerViewController(cityId: $0.id)
        })
        viewController.title = "Выбор города"
        show(viewController, sender: nil)
    }
    
    private func presentServiceCenterPickerViewController(cityId: Int) {
        let interactor = self.interactor.createRepairPointsInteractor(cityId: cityId)
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = $1.name
        }, select: { [weak self] in
            guard let viewController = self?.viewControllers.first as? OrderRepairMenuViewController else { return }
            viewController.setRepairPoint($0)
            self?.popToRootViewController(animated: IsAnimationAllowed())
        })
        viewController.title = "Выбор СЦ"
        show(viewController, sender: nil)
    }
    
    private func presentRepairOrderCompletionMessage(response: MessageResponse, close: (() -> Void)?) {
        let viewController = UIAlertController(title: "Спасибо, заявка принята! В ближайшее время с Вами свяжется наш менеджер.", message: nil, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in
            close?()
        }))
        present(viewController, animated: IsAnimationAllowed())
    }
    
}

extension OrderRepairNavigationController: TextViewControllerDelegate {
    
    private func presentCommentViewController(comment: String?) {
        let viewController = TextViewController()
        viewController.loadViewIfNeeded()
        viewController.title = "Комментарий"
        viewController.textView.text = comment
        viewController.textLabel.text = nil
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func textViewController(_ viewController: TextViewController, didCompleteWithText text: String?) {
        guard let viewController = viewControllers.first as? OrderRepairMenuViewController else { return }
        viewController.setComment(text)
        popToRootViewController(animated: IsAnimationAllowed())
    }
    
}
