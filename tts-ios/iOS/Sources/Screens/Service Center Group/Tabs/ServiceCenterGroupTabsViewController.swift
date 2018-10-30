//
//  ServiceCenterGroupTabsViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 19/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import GoogleMaps

private let kMapViewHeight: CGFloat = 160

final class ServiceCenterGroupTabsViewController: UIViewController, ErrorPresenting {
    
    private var mapView: GMSMapView?
    private var marker: GMSMarker?
    
    private let interactor: ServiceCenterGroupTabsInteractor
    private let spinner = UIActivityIndicatorView(style: .white)
    private var selectedBrandId: Int?
    
    init(interactor: ServiceCenterGroupTabsInteractor, selectedBrandId: Int?) {
        self.interactor = interactor
        self.selectedBrandId = selectedBrandId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor.observeData { [weak self] in
            self?.data = $0
        }
        
        reloadData()
    }
    
    private func updateMapView(group: ServiceCenterGroup) {
        let coordinate = group.coordinate
        
        // map view
        if mapView == nil {
            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 14.0)
            let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: view.bounds.width, height: kMapViewHeight), camera: camera)
            mapView.backgroundColor = .clear
            mapView.autoresizingMask = .flexibleWidth
            mapView.isUserInteractionEnabled = false
            self.mapView = mapView
            view.addSubview(mapView)
            
            if let url = Bundle.main.url(forResource: "GoogleMapsStyle", withExtension: "json") {
                mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: url)
            }
        } else {
            let update = GMSCameraUpdate.setTarget(coordinate)
            mapView?.moveCamera(update)
        }
        
        // marker
        if let marker = marker {
            marker.position = coordinate
        } else {
            marker = GMSMarker(position: coordinate)
            marker?.tracksViewChanges = true
            marker?.map = mapView
        }
        
        // icon view
        marker?.iconView = ServiceCenterIconView(group: group, completion: { [weak self] in
            self?.marker?.tracksViewChanges = false
        })
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateChildViewControllersLayoutGuideInsets()
    }
    
    private func updateChildViewControllersLayoutGuideInsets() {
        guard let tabLayoutViewController = tabLayoutViewController, tabLayoutViewController.isViewLoaded else { return }
        tabLayoutViewController.view.layoutIfNeeded()
        
        let bounds = tabLayoutViewController.containerView.convert(tabLayoutViewController.containerView.bounds, to: view)
        let top = max(0, topLayoutGuide.length - bounds.minY)
        let bottom = max(0, bottomLayoutGuide.length - (view.bounds.maxY - bounds.maxY))
        
        tabLayoutViewController.viewControllers.forEach {
            ($0 as? ParentViewControllerLayoutGuidesObserving)?.parentViewControllerDidLayoutSubviews(topLayoutGuideLength: top, bottomLayoutGuideLength: bottom)
        }
    }
    
    // MARK: - Loading Data
    
    private func reloadData() {
        setIsLoading(true)
        interactor.reloadData { [weak self] in
            self?.setIsLoading(false)
            if let error = $0.error {
                self?.showError(error)
            }
        }
    }
    
    // MARK: - Managing the Data
    
    var data: (ServiceCenterGroup, [URL: UIImage])? {
        didSet {
            guard isViewLoaded else { return }
            if let group = data?.0 {
                updateMapView(group: group)
            }
            updateChildViewControllers()
        }
    }
    
    // MARK: - Managing Child View Controllers
    
    private func updateChildViewControllers() {
        if let services = data?.0.services, let images = data?.1, services.count > 0 {
            removeServicesEmptyViewController()
            setServicesViewControllers(services: services, images: images)
        } else {
            removeServicesViewControllers()
            addServicesEmptyViewController()
        }
    }
    
    private var servicesEmptyViewController: UIViewController?
    
    private func addServicesEmptyViewController() {
        if servicesEmptyViewController == nil {
//            servicesEmptyViewController = GarageMainEmptyViewController(call: call)
//            servicesEmptyViewController?.delegate = self
        }
        
//        let viewController = servicesEmptyViewController!
//        if viewController.parent != self {
//            addChildViewController(viewController)
//            viewController.view.frame = CGRect(x: 0, y: kMapViewHeight, width: view.bounds.width, height: view.bounds.height - kMapViewHeight)
//            viewController.view.autoresizingMask = .flexibleDimensions
//            view.addSubview(viewController.view)
//            viewController.didMove(toParentViewController: self)
//        }
    }
    
    private func removeServicesEmptyViewController() {
        guard let viewController = servicesEmptyViewController else { return }
        
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        servicesEmptyViewController = nil
    }
    
    private var tabLayoutViewController: TabLayoutViewController?
    
    private func setServicesViewControllers(services: [ServiceCenter], images: [URL: UIImage]) {
        if tabLayoutViewController != nil {
            removeServicesViewControllers()
        }
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let viewControllers: [ServiceCenterViewController] = services.map {
            var image: UIImage?
            if let brandImage = $0.brandImage {
                image = images[brandImage]
            }
            
            let bind = $0.brandId.flatMap { interactor.createBindAction(brandId: $0) }
            return ServiceCenterViewController(image: image, interactor: interactor.createServiceCenterInteractor(serviceId: $0.id), bind: bind)
        }
        
        let viewController = TabLayoutViewController(viewControllersForPagerTabStripController: viewControllers, didChangeCurrentIndex: { [weak self] in
            self?.tabLayoutViewControllerDidChangeCurrentIndex($0)
        })
        viewController.settings.style.buttonBarHeight = 52
        viewController.settings.style.buttonBarLeftContentInset = 12
        viewController.settings.style.buttonBarRightContentInset = viewController.settings.style.buttonBarLeftContentInset
        viewController.settings.style.selectedBarHeight = 1
        
        viewController.view.frame = CGRect(x: 0, y: kMapViewHeight, width: view.bounds.width, height: view.bounds.height - kMapViewHeight)
        viewController.view.autoresizingMask = .flexibleDimensions
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        tabLayoutViewController = viewController
        
        updateChildViewControllersLayoutGuideInsets()
        
        let currentIndex = selectedBrandId.flatMap({ brandId in services.index { $0.brandId == brandId } }) ?? 0
        if viewController.currentIndex != currentIndex {
            viewController.moveToViewController(at: currentIndex, animated: false)
        }
        
        tabLayoutViewControllerDidChangeCurrentIndex(currentIndex)
    }
    
    private func removeServicesViewControllers() {
        guard let viewController = tabLayoutViewController else { return }
        
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        tabLayoutViewController = nil
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    private func tabLayoutViewControllerDidChangeCurrentIndex(_ currentIndex: Int) {
        selectedBrandId = data?.0.services[currentIndex].brandId
    }
    
    // MARK: - Loading Indication
    
    private var isLoading = false
    private func setIsLoading(_ loading: Bool) {
        if loading {
            spinner.frame = view.bounds
            spinner.autoresizingMask = .flexibleMargins
            view.addSubview(spinner)
            spinner.startAnimating()
        } else {
            spinner.removeFromSuperview()
        }
        isLoading = loading
    }
    
}
