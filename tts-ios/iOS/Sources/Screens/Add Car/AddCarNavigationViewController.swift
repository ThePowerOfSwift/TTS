//
//  AddCarNavigationViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import SwiftMessages

final class AddCarNavigationViewController: NavigationController, AddCarStep1ViewControllerDelegate, AddCarStep2ViewControllerDelegate, AddCarStep3ViewControllerDelegate, BrandListViewControllerDelegate {
    
    private var interactor: AddCarInteractor!
    private var success: ((SwiftMessages.Config, MessageView) -> Void)?
    
    init(interactor: AddCarInteractor, success: ((SwiftMessages.Config, MessageView) -> Void)?) {
        super.init(style: .barTintColor(UIColor(r: 19, g: 25, b: 43)), tintColor: .white, barStyle: .black)
        self.interactor = interactor
        self.success = success
        presentStep1ViewController(animated: false)
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Presenting Step 1
    
    private func presentStep1ViewController(animated: Bool) {
        let viewController = AddCarStep1ViewController()
        viewController.delegate = self
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_close"), style: .done) { [weak self] in
            self?.dismiss(animated: IsAnimationAllowed(), completion: nil)
        }
        setViewControllers([viewController], animated: animated)
    }
    
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didSelectCellWithBrand brand: CarBrand?, model: NamedValue?) {
        presentBrandListViewController(brand: brand, model: model)
    }
    
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didSelectCellWithYear year: Int?) {
        presentYearListViewController(year: year)
    }
    
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didSelectCellWithEquipment equipment: CarEquipment?, brandId: Int, modelId: Int, year: Int) {
        presentEquipmentsViewController(equipment: equipment, brandId: brandId, modelId: modelId, year: year)
    }
    
    func addCarStep1ViewController(_ viewController: AddCarStep1ViewController, didCompleteWithBrand brand: CarBrand, modelId: Int, year: Int, complectationId: Int?) {
        presentStep2ViewController(brand: brand, modelId: modelId, year: year, complectationId: complectationId, animated: IsAnimationAllowed())
    }
    
    // MARK: - Presenting Step 2
    
    private func presentStep2ViewController(brand: CarBrand, modelId: Int, year: Int, complectationId: Int?, animated: Bool) {
        let viewController = AddCarStep2ViewController(brand: brand, modelId: modelId, year: year, complectationId: complectationId)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func addCarStep2ViewController(_ viewController: AddCarStep2ViewController, didCompleteWithBrand brand: CarBrand, modelId: Int, year: Int, complectationId: Int?, gosnomer: String, vin: String, mileage: Int) {
        presentStep3ViewController(brand: brand, modelId: modelId, year: year, gosnomer: gosnomer, vin: vin, mileage: mileage, animated: IsAnimationAllowed())
    }
    
    // MARK: - Presenting Step 3
    
    private func presentStep3ViewController(brand: CarBrand, modelId: Int, year: Int, gosnomer: String, vin: String, mileage: Int, animated: Bool) {
        let interactor = self.interactor.createAddCarStep3Interactor()
        let viewController = AddCarStep3ViewController(interactor: interactor, brand: brand, modelId: modelId, year: year, gosnomer: gosnomer, vin: vin, mileage: mileage)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func addCarStep3ViewControllerDidComplete(_ viewController: AddCarStep3ViewController) {
        viewController.dismiss(animated: IsAnimationAllowed(), completion: {
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: UIWindow.Level.normal.rawValue)
            config.preferredStatusBarStyle = .lightContent
            let view = MessageView(text: "Авто добавлено")
            self.success?(config, view)
        })
    }
    
    // MARK: - Presenting Brands
    
    private func presentBrandListViewController(brand: CarBrand?, model: NamedValue?) {
        let interactor = self.interactor.createBrandListInteractor()
        let viewController = BrandListViewController(interactor: interactor)
        viewController.delegate = self
        show(viewController, sender: nil)
    }
    
    func brandListViewController(_ viewController: BrandListViewController, didSelectBrand brand: CarBrand) {
        fatalError("Should never be called")
    }
    
    func brandListViewController(_ viewController: BrandListViewController, didSelectBrand brand: CarBrand, model: NamedValue) {
        guard let viewController = viewControllers.first as? AddCarStep1ViewController else { return }
        viewController.setCarBrandAndModel((brand, model))
        popToRootViewController(animated: IsAnimationAllowed())
    }
    
    // MARK: - Presenting Year
    
    private func presentYearListViewController(year: Int?) {
        let interactor = self.interactor.createYearInteractor()
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = String($1)
        }, select: { [weak self] in
            guard let viewController = self?.viewControllers.first as? AddCarStep1ViewController else { return }
            viewController.setCarYear($0)
            self?.popToRootViewController(animated: IsAnimationAllowed())
        })
        viewController.title = "Комплектация"
        show(viewController, sender: nil)
    }
    
    // MARK: - Presenting Equipments
    
    private func presentEquipmentsViewController(equipment: CarEquipment?, brandId: Int, modelId: Int, year: Int) {
        let interactor = self.interactor.createEquipmentsInteractor(brandId: brandId, modelId: modelId, year: year)
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = $1.name
        }, select: { [weak self] in
            guard let viewController = self?.viewControllers.first as? AddCarStep1ViewController else { return }
            viewController.setEquipment($0)
            self?.popToRootViewController(animated: IsAnimationAllowed())
        })
        viewController.title = "Комплектация"
        show(viewController, sender: nil)
    }
    
    // MARK: - Presenting Cities
    
    func addCarStep3ViewController(_ viewController: AddCarStep3ViewController, didSelectCellWithCity city: NamedValue?) {
        let interactor = self.interactor.createCitiesInteractor()
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = $1.name
        }, select: { [weak self] in
            (self?.viewControllers.first { $0 is AddCarStep3ViewController } as? AddCarStep3ViewController)?.setCity($0)
            self?.popViewController(animated: IsAnimationAllowed())
        })
        viewController.title = "Выбор города"
        show(viewController, sender: nil)
    }
    
    // MARK: - Presenting Service Centers
    
    func addCarStep3ViewController(_ viewController: AddCarStep3ViewController, didSelectServiceCenterCellWithBrand brand: CarBrand, city: NamedValue, serviceCenter: ServiceCenter?) {
        let interactor = self.interactor.createServiceCenterInteractor(cityId: city.id, brandId: brand.id)
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = $1.address
        }, select: { [weak self] in
            (self?.viewControllers.first { $0 is AddCarStep3ViewController } as? AddCarStep3ViewController)?.setServiceCenter($0)
            self?.popViewController(animated: IsAnimationAllowed())
        })
        viewController.title = "Выбор города"
        show(viewController, sender: nil)
    }
    
}
