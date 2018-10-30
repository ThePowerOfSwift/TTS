//
//  OrderTechServiceNavigationController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 22/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class OrderTechServiceNavigationController: NavigationController {
    
    private var interactor: OrderTechServiceInteractor!
    private var close: ((OrderTechServiceNavigationController) -> Void)?
    
    init(interactor: OrderTechServiceInteractor, close: ((OrderTechServiceNavigationController) -> Void)?) {
        super.init(style: .barTintColor(UIColor(r: 19, g: 25, b: 43)), tintColor: .white, barStyle: .black)
        self.interactor = interactor
        self.close = close

        let viewController = OrderTechServiceSelectViewController()
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

extension OrderTechServiceNavigationController: OrderTechServiceSelectViewControllerDelegate {
    
    func orderTechServiceSelectViewControllerDidClose(_ viewController: OrderTechServiceSelectViewController) {
        close?(self)
    }
    
    func orderTechServiceSelectViewControllerDidSelectTechService(_ viewController: OrderTechServiceSelectViewController) {
        presentOrderTechServiceMileageViewController(animated: IsAnimationAllowed())
    }
    
    func orderTechServiceSelectViewController(_ viewController: OrderTechServiceSelectViewController, didSelectStandardOperationsWithOtherWork otherWork: String?) {
        presentOrderTechServiceOtherWorkViewController(otherWork: otherWork)
    }
    
    func orderTechServiceSelectViewController(_ viewController: OrderTechServiceSelectViewController, didConfirmOrderTechServiceSelection selection: OrderTechServiceSelection) {
        presentOrderTechServiceVariantsViewController(selection: selection)
    }
    
}

extension OrderTechServiceNavigationController: TextViewControllerDelegate {
    
    func presentOrderTechServiceOtherWorkViewController(otherWork: String?) {
        let viewController = TextViewController()
        viewController.loadViewIfNeeded()
        viewController.title = "Стандартные операции"
        viewController.textView.text = otherWork
        viewController.textLabel.text = "Перечислите виды работ, которые вы хотели бы провести в вашем автомобиле"
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func textViewController(_ viewController: TextViewController, didCompleteWithText text: String?) {
        guard let viewController = viewControllers.first(where: {$0 is OrderTechServiceSelectViewController}) as? OrderTechServiceSelectViewController else { return }
        viewController.otherWork = text
        popToViewController(viewController, animated: IsAnimationAllowed())
    }

}

extension OrderTechServiceNavigationController: OrderTechServiceMileageViewControllerDelegate {
    
    func presentOrderTechServiceMileageViewController(animated: Bool) {
        let interactor = self.interactor.createOrderTechServiceMileageInteractor()
        let viewController = OrderTechServiceMileageViewController(interactor: interactor)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func orderTechServiceMileageViewController(_ viewController: OrderTechServiceMileageViewController, didCompleteWithList list: OrderTechServiceGetListResponse) {
        presentOrderTechServiceProposeViewController(list: list)
    }
    
}

extension OrderTechServiceNavigationController: OrderTechServiceProposeViewControllerDelegate {
    
    func presentOrderTechServiceProposeViewController(list: OrderTechServiceGetListResponse) {
        let interactor = self.interactor.createOrderTechServiceProposeInteractor(list: list)
        let viewController = OrderTechServiceProposeViewController(interactor: interactor)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func orderTechServiceProposeViewController(_ viewController: OrderTechServiceProposeViewController, didTapServiceListButtonWithList list: OrderTechServiceGetListResponse) {
        presentOrderTechServiceListViewController(list: list, success: { [weak viewController] in
            viewController?.service = $0
        }, cancel: nil)
    }
    
    func orderTechServiceProposeViewController(_ viewController: OrderTechServiceProposeViewController, didCompleteWithService service: OrderTechServiceGetListResponse.Service, details: OrderTechServiceGetDetailResponse) {
        presentOrderTechServiceDetailSelectViewController(service: service, details: details)
    }
    
    func orderTechServiceProposeViewControllerDidClose(_ viewController: OrderTechServiceProposeViewController) {
        close?(self)
    }
    
    func presentOrderTechServiceListViewController(list: OrderTechServiceGetListResponse, success: ((OrderTechServiceGetListResponse.Service) -> Void)?, cancel: (() -> Void)?) {
        let interactor = self.interactor.createOrderTechServiceListInteractor(list: list)
        let viewController = OrderTechServiceListViewController(interactor: interactor)
        let navigationController = NavigationController(style: (navigationBar as? NavigationBar)?.style ?? .transparent, tintColor: navigationBar.tintColor, barStyle: navigationBar.barStyle)
        navigationController.viewControllers = [viewController]
        viewController.onSelect = { [weak navigationController] in
            success?($0)
            navigationController?.dismiss(animated: IsAnimationAllowed(), completion: nil)
        }
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_close"), style: .plain, block: { [weak navigationController] in
            navigationController?.dismiss(animated: IsAnimationAllowed(), completion: nil)
            cancel?()
        })
        present(navigationController, animated: IsAnimationAllowed(), completion: nil)
    }
    
}

extension OrderTechServiceNavigationController: OrderTechServiceDetailSelectViewControllerDelegate {
    
    func presentOrderTechServiceDetailSelectViewController(service: OrderTechServiceGetListResponse.Service, details: OrderTechServiceGetDetailResponse) {
        let interactor = self.interactor.createOrderTechServiceDetailSelectInteractor(service: service, details: details)
        let viewController = OrderTechServiceDetailSelectViewController(interactor: interactor)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func orderTechServiceDetailSelectViewController(_ viewController: OrderTechServiceDetailSelectViewController, didSelectService service: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail) {
        presentServiceDetailViewController(service: service, detail: detail)
    }
    
}

extension OrderTechServiceNavigationController: OrderTechServiceDetailViewControllerDelegate {

    func presentServiceDetailViewController(service: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail) {
        let interactor = self.interactor.createOrderTechServiceDetailInteractor(service: service, detail: detail)
        let viewController = OrderTechServiceDetailViewController(interactor: interactor)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func orderTechServiceDetailViewController(_ viewController: OrderTechServiceDetailViewController, didConfirmService service: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail) {
        guard let viewController = viewControllers.first(where: {$0 is OrderTechServiceSelectViewController}) as? OrderTechServiceSelectViewController else { return }
        viewController.setOrderTechService(service: service, detail: detail)
        popToViewController(viewController, animated: IsAnimationAllowed())
    }
    
}

extension OrderTechServiceNavigationController: OrderTechServiceVariantsViewControllerDelegate {
    
    func presentOrderTechServiceVariantsViewController(selection: OrderTechServiceSelection) {
        let interactor = self.interactor.createOrderTechServiceVariantsInteractor(selection: selection)
        let viewController = OrderTechServiceVariantsViewController(interactor: interactor)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func orderTechServiceVariantsViewController(_ viewController: OrderTechServiceVariantsViewController, didSelectVariant variant: OrderTechServiceGetVariantsResponse.Variant, auto: UserAuto, serviceCenter: ServiceCenter, selection: OrderTechServiceSelection) {
        presentOrderTechServiceAppointmentViewController(auto: auto, serviceCenter: serviceCenter, selection: selection, variant: variant)
    }
    
}

extension OrderTechServiceNavigationController: OrderTechServiceAppointmentViewControllerDelegate {
    
    func presentOrderTechServiceAppointmentViewController(auto: UserAuto, serviceCenter: ServiceCenter, selection: OrderTechServiceSelection, variant: OrderTechServiceGetVariantsResponse.Variant) {
        let interactor = self.interactor.createOrderTechServiceAppointmentConfirmInteractor(selection: selection, variant: variant)
        let viewController = OrderTechServiceAppointmentViewController(interactor: interactor)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func orderTechServiceAppointmentViewController(_ viewController: OrderTechServiceAppointmentViewController, didCompleteWithAppointment appointment: OrderTechServiceAppointmentDTO) {
        presentOrderTechServiceAppointmentCompletionMessage(date: appointment.period.lowerBound, address: appointment.serviceCenter.address, close: { [weak self] in
            guard let `self` = self else { return }
            self.close?(self)
        })
    }
    
    private func presentOrderTechServiceAppointmentCompletionMessage(date: Date, address: String, close: (() -> Void)?) {
        let dateString: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.ru_RU
            dateFormatter.dateFormat = "dd' 'MMMM 'в 'HH:mm"
            return dateFormatter.string(from: date)
        }()
        
        let viewController = UIAlertController(title: "Заявка принята!", message: "Ждем \(dateString) по адресу \(address). При необходимости с вами свяжется оператор.", preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in
            close?()
        }))
        present(viewController, animated: IsAnimationAllowed())
    }
    
}
