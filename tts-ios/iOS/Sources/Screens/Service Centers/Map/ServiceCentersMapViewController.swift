//
//  ServiceCentersMapViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import GoogleMaps
import TTSKit
import RxSwift

final class ServiceCentersMapViewController: UIViewController, IndicatorInfoProvider, GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterRendererDelegate, ServiceCentersFilterable {
    
    private let interactor: ServiceCentersMapInteractor
    private let call: CallAction
    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    
    init(interactor: ServiceCentersMapInteractor, call: CallAction) {
        self.interactor = interactor
        self.call = call
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Providing Indicator Info
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "На карте")
    }
    
    // MARK: - Managing the View
    
    override func loadView() {
        super.loadView()
        
        // map view configuring
        let coordinate = CLLocationCoordinate2D(latitude: 55.810823, longitude: 49.06704946) // Kazan
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 11.0)
        let mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = .flexibleDimensions
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        if let button = mapView.myLocationButton {
            button.setImage(#imageLiteral(resourceName: "location_arrow"), for: .normal)
            let backgroundImage = ImageDrawer.default.draw(BezierPathImage(fillColor: UIColor(r: 37, g: 42, b: 57), radius: button.bounds.width / 2), in: button.bounds)
            button.setBackgroundImage(backgroundImage, for: .normal)
        }
        self.mapView = mapView
        view.addSubview(mapView)
        
        // clustering
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: ClusterIconGenerator())
        clusterManager = GMUClusterManager(map: mapView, algorithm: GMUNonHierarchicalDistanceBasedAlgorithm(), renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        renderer.delegate = self
        
        // styling
        if let url = Bundle.main.url(forResource: "GoogleMapsStyle", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeData(brand: nil, city: nil)
    }
    
    // MARK: - Responding to Changes in Child View Controllers
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        guard let viewController = container as? ServiceCentersMapMarkerViewController else { return }
        let isExpanding = container.preferredContentSize.height > viewController.view.bounds.height
        if isExpanding {
            updateMarkerViewControllerHeight()
        }
        UIView.animate(withDuration: 0.22, animations: {
            self.updateMarkerViewControllerOrigin()
        }, completion: { _ in
            if !isExpanding {
                self.updateMarkerViewControllerHeight()
            }
        })
    }

    private func updateMarkerViewControllerOrigin() {
        guard let viewController = children.first(where: {$0 is ServiceCentersMapMarkerViewController}) as? ServiceCentersMapMarkerViewController else { return }
        
        viewController.view.frame = CGRect(x: 0, y: view.bounds.height - bottomLayoutGuide.length - viewController.preferredContentSize.height, width: view.bounds.width, height: viewController.view.frame.height)
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: viewController.preferredContentSize.height, right: 0)
    }
    
    private func updateMarkerViewControllerHeight() {
        guard let viewController = children.first(where: {$0 is ServiceCentersMapMarkerViewController}) as? ServiceCentersMapMarkerViewController else { return }
        
        let height = viewController.preferredContentSize.height
        viewController.view.frame = CGRect(x: 0, y: viewController.view.frame.minY, width: view.bounds.width, height: height)
    }
    
    // MARK: - Managing Items
    
    private var items: [ServiceCenterGroup]? {
        didSet {
            guard isViewLoaded else { return }
            updateItems()
        }
    }
    
    private func updateItems() {
        clusterManager.clearItems()
        let background = BezierPathImage(fillColor: UIColor(r: 37, g: 42, b: 57))
        items?.forEach { clusterManager.add(ServiceCentersGroupItem(group: $0, background: background)) }
        clusterManager.cluster()
    }
    
    func observeData(brand: CarBrand?, city: NamedValue?) {
        interactor.observeData(brand: brand, city: city, onNext: { [weak self] in
            self?.items = $0
        })
    }
    
    func applyFilter(brand: CarBrand?, city: NamedValue?) {
        observeData(brand: brand, city: city)
    }
    
    // MARK: - Map View

    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        guard let item = clusterItem as? ServiceCentersGroupItem else { return false }
        
        if let viewController = children.first(where: {$0 is ServiceCentersMapMarkerViewController}) as? ServiceCentersMapMarkerViewController {
            viewController.setServiceCenterGroup(latitude: item.group.coordinatesLatitude, longitude: item.group.coordinatesLongitude)
        } else {
            let interactor = self.interactor.createServiceCentersMapMarkerInteractor()
            let viewController = ServiceCentersMapMarkerViewController(interactor: interactor, call: call)
            viewController.setServiceCenterGroup(latitude: item.group.coordinatesLatitude, longitude: item.group.coordinatesLongitude)
            if #available(iOS 11.0, *) {
                viewController.view.layer.cornerRadius = 8
                viewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                viewController.view.clipsToBounds = true
            }
            addChild(viewController)
            view.addSubview(viewController.view)
            view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            updateMarkerViewControllerOrigin()
            updateMarkerViewControllerHeight()
            viewController.didMove(toParent: self)
        }
        
        return true
    }
    
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        guard let item = object as? ServiceCentersGroupItem else { return nil }
        let marker = GMSMarker(position: item.position)
        marker.tracksViewChanges = true
        marker.iconView = ServiceCenterIconView(group: item.group, completion: { [weak marker] in
            marker?.tracksViewChanges = false
        })
        return marker
    }
    
    func myLocationObservable() -> Observable<CLLocation?> {
        if !isViewLoaded {
            loadView()
            viewDidLoad()
        }
        
        return KVOObservable<CLLocation>(target: mapView, keyPath: "myLocation").asObservable()
    }
    
}
