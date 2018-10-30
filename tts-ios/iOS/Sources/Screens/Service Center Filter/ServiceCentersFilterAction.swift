//
//  ServiceCentersFilterAction.swift
//  tts
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class ServiceCentersFilterAction: BrandListViewControllerDelegate {
    
    private weak var presentingViewController: UIViewController?
    private let interactor: ServiceCentersFilterInteractor
    private weak var navigationController: UINavigationController?
    private weak var serviceCentersFilterViewController: ServiceCentersFilterViewController?
    
    init(presentingViewController: UIViewController, interactor: ServiceCentersFilterInteractor) {
        self.presentingViewController = presentingViewController
        self.interactor = interactor
    }
    
    func presentInitialViewController(brand: CarBrand?, city: NamedValue?, update: @escaping (CarBrand?, NamedValue?) -> Void, cancel: @escaping () -> Void) {
        let viewController = ServiceCentersFilterViewController(interactor: interactor, brandSelected: { [weak self] in
            self?.presentBrandListViewController(brand: $0)
        }, citySelected: { [weak self] in
            self?.presentCitiesViewController(city: $0)
        }, apply: { [weak self] brand, city in
            self?.presentingViewController?.dismiss(animated: IsAnimationAllowed(), completion: {
                update(brand, city)
            })
        }, close: { [weak self] in
            self?.presentingViewController?.dismiss(animated: IsAnimationAllowed(), completion: cancel)
        })
        viewController.setBrand(brand)
        viewController.setCity(city)
        serviceCentersFilterViewController = viewController
        
        let navigationController = NavigationController(style: .barTintColor(UIColor(r: 19, g: 25, b: 43)), tintColor: .white, barStyle: .black)
        navigationController.viewControllers = [viewController]

        presentingViewController?.present(navigationController, animated: IsAnimationAllowed())
        self.navigationController = navigationController
    }
    
    // MARK: - Presenting Cities
    
    func presentCitiesViewController(city: NamedValue?) {
        let interactor = self.interactor.createCitiesInteractor()
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = $1.name
        }, select: { [weak self] in
            self?.serviceCentersFilterViewController?.setCity($0)
            self?.navigationController?.popViewController(animated: IsAnimationAllowed())
        })
        viewController.title = "Выбор города"
        navigationController?.show(viewController, sender: nil)
    }
    
    // MARK: - Presenting Brands
    
    private func presentBrandListViewController(brand: CarBrand?) {
        let interactor = self.interactor.createBrandListInteractor()
        let viewController = BrandListViewController(interactor: interactor)
        viewController.shouldSelectModel = false
        viewController.delegate = self
        navigationController?.show(viewController, sender: nil)
    }
    
    func brandListViewController(_ viewController: BrandListViewController, didSelectBrand brand: CarBrand) {
        serviceCentersFilterViewController?.setBrand(brand)
        navigationController?.popViewController(animated: IsAnimationAllowed())
    }
    
    func brandListViewController(_ viewController: BrandListViewController, didSelectBrand brand: CarBrand, model: NamedValue) {
        fatalError("Should never be called")
    }
    
}
