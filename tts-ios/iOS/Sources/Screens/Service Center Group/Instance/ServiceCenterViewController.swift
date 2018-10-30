//
//  ServiceCenterViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 19/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import XLPagerTabStrip
import AlamofireImage
import NYTPhotoViewer
import SwiftMessages

final class ServiceCenterViewController: UIViewController, ErrorPresenting, IndicatorInfoProvider, ParentViewControllerLayoutGuidesObserving, UICollectionViewDelegate, UICollectionViewDataSource, NYTPhotosViewControllerDelegate {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var addressContainerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var phoneContainerView: UIView!
    @IBOutlet private var phoneButton: UIButton!
    @IBOutlet private var workingTimeContainerView: UIView!
    @IBOutlet private var workingTimeLabel: UILabel!
    @IBOutlet private var addAutoContainerView: UIView!
    @IBOutlet private var photosContainerView: UIView!
    @IBOutlet private var photosCollectionView: UICollectionView!
    @IBOutlet private var photosLabel: UILabel!
    @IBOutlet private var serviceListContainerView: UIView!
    @IBOutlet private var serviceListLabel: UILabel!
    private let photosContainerViewGradientLayer = CAGradientLayer()
    
    private let image: UIImage?
    private let interactor: ServiceCenterInteractor
    private let bind: BindServiceCenterAction?
    
    init(image: UIImage?, interactor: ServiceCenterInteractor, bind: BindServiceCenterAction?) {
        self.image = image
        self.interactor = interactor
        self.bind = bind
        super.init(nibName: nil, bundle: nil)
        
        interactor.observeData { [weak self] in
            self?.service = $0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosContainerViewGradientLayer.colors = [UIColor(white: 0, alpha: 0.4).cgColor, UIColor.clear.cgColor]
        photosContainerView.layer.addSublayer(photosContainerViewGradientLayer)
        
        photosCollectionView.register(ServiceCenterImageCell.nib, forCellWithReuseIdentifier: "cell")
        updateServiceCenter()
        
        updateScrollViewBottomInsetIfNeeded()
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        photosContainerViewGradientLayer.frame = CGRect(x: 0, y: 0, width: photosContainerView.bounds.width, height: 64)
        
        guard let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.sectionInset = .zero
        layout.itemSize = photosCollectionView.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }
    
    // MARK: - Observing Layout Guides
    
    private var bottomLayoutGuideLength: CGFloat = 0 {
        didSet {
            updateScrollViewBottomInsetIfNeeded()
        }
    }
    
    private func updateScrollViewBottomInsetIfNeeded() {
        guard isViewLoaded else { return }
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            scrollView.scrollIndicatorInsets.bottom = bottomLayoutGuideLength
            scrollView.contentInset.bottom = bottomLayoutGuideLength
        }
    }
    
    func parentViewControllerDidLayoutSubviews(topLayoutGuideLength: CGFloat, bottomLayoutGuideLength: CGFloat) {
        self.bottomLayoutGuideLength = bottomLayoutGuideLength
    }
    
    // MARK: - Managing Data
    
    private var service: ServiceCenter? {
        didSet {
            guard isViewLoaded else { return }
            updateServiceCenter()
        }
    }
    
    private func updateServiceCenter() {
        if let brandName = service?.brandName {
            titleLabel.text = "Сервис " + brandName
        } else {
            titleLabel.text = "Сервис"
        }
        
        addressLabel.text = service?.address
        
        if let phone = service?.phone.first {
            let string = PhoneNumberFormatter().string(from: phone)
            phoneButton.setTitle(string, for: .normal)
        } else {
            phoneButton.setTitle(nil, for: .normal)
        }
        
        workingTimeLabel.text = service?.workingTime.joined(separator: ", ")
        
        stackView.arrangedSubviews.filter {$0 is ServiceCenterUserAutoView}.forEach {stackView.removeArrangedSubview($0)}
        if let autos = service?.auto {
            for (index, auto) in zip(0..<autos.count, autos) {
                let subview = ServiceCenterUserAutoView.loadFromNib()!
                subview.heightAnchor.constraint(equalToConstant: 64).isActive = true
                subview.titleLabel.text = auto.brand
                subview.imageView.af_setImage(withURL: auto.image, filter: AspectScaledToFitSizeFilter(size: subview.imageView.bounds.size))
                stackView.insertArrangedSubview(subview, at: 3 + index)
            }
        }
        
        if let images = service?.moreImages, images.count > 0 {
            photosContainerView.isHidden = false
            photosLabel.text = String(describing: images.count) + " фото"
            photosCollectionView.reloadData()
        } else {
            photosContainerView.isHidden = true
        }
        
        if let strings = service?.serviceList, strings.count > 0 {
            serviceListContainerView.isHidden = false
            serviceListLabel.attributedText = strings.joined(separator: "\n").with(StringAttributes {
                $0.foregroundColor = .white
                $0.font = .systemFont(ofSize: 15)
                $0.paragraphSpacing = 8
            })
        } else {
            serviceListContainerView.isHidden = true
        }
    }
    
    // MARK: - Providing Indicator Info
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if let image = image {
            return IndicatorInfo(image: image)
        } else {
            return IndicatorInfo(title: service?.brandName)
        }
    }
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return service?.moreImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ServiceCenterImageCell {
            cell.image = service?.moreImages?[indexPath.row]
        }
        return  cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let urls = service?.moreImages else { return }
        
        let dataSource = PhotoViewerDataSource(urls: urls, downloader: ImageDownloader.default) { [weak self] item in
            self?.photosViewController?.update(item)
        }
        photosDataSource = dataSource
        
        let viewController = NYTPhotosViewController(dataSource: dataSource, initialPhotoIndex: indexPath.row, delegate: self)
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
        photosViewController = viewController
    }
    
    // MARK: - Actions
    
    @IBAction
    private func callServiceCenter() {
        guard let phone = service?.phone.first else { return }
        CallAction.call(phone: phone, completion: nil)
    }
    
    @IBAction
    private func bindServiceCenter() {
        guard let service = service else { return }
        
        bind?.run(presentingViewController: self, uid: service.uid, completion: { [weak self] in
            switch $0 {
            case .succeeded:
                self?.showCarBindingSuccessMessage()
            case .cancelled:
                () // do nothing
            case .noUserAutos:
                var text = "Нет доступных автомобилей для привязки к сервисному центру"
                if let brandName = service.brandName {
                    text += " \(brandName)"
                }
                self?.showError(title: text, message: nil, animated: IsAnimationAllowed())
            case .error:
                () // error has been presented by the bind action, so nothing to do here
            }
        })
    }
    
    private func showCarBindingSuccessMessage() {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal.rawValue)
        config.preferredStatusBarStyle = .lightContent
        let view = MessageView(text: "Автомобиль успешно привязан", style: .blue)
        view.statusBarOffset = UIApplication.shared.statusBarFrame.height
        view.safeAreaTopOffset = UIApplication.shared.statusBarFrame.height + 44
        SwiftMessages.show(config: config, view: view)
    }
    
    // MARK: - Photo Viewer
    
    private weak var photosViewController: NYTPhotosViewController?
    private var photosDataSource: PhotoViewerDataSource?
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, titleFor photo: NYTPhoto, at photoIndex: Int, totalPhotoCount: NSNumber?) -> String? {
        return String(format: "%d из %d", photoIndex + 1, totalPhotoCount?.intValue ?? 0)
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, maximumZoomScaleFor photo: NYTPhoto) -> CGFloat {
        if let image = photo.image {
            return maximumZoomScaleFor(width: image.size.width, height: image.size.height)
        } else if let photo = photo as? PhotoViewerItem {
            let filename = photo.url.absoluteString.components(separatedBy: "/").last!
            let re = try! NSRegularExpression(pattern: "(\\d*)x(\\d*)", options: []) // swiftlint:disable:this force_try
            if let match = re.matches(in: filename, options: [], range: NSRange(location: 0, length: filename.count)).first, match.numberOfRanges == 3 {
                let left = (filename as NSString).substring(with: match.range(at: 1))
                let right = (filename as NSString).substring(with: match.range(at: 2))
                let formatter = NumberFormatter()
                if let width = formatter.number(from: left) as? CGFloat, let height = formatter.number(from: right) as? CGFloat {
                    let scale = view.window?.screen.scale ?? UIScreen.main.scale
                    return maximumZoomScaleFor(width: width / scale, height: height / scale)
                }
            }
        }
        
        return 1
    }
    
    private func maximumZoomScaleFor(width: CGFloat, height: CGFloat) -> CGFloat {
        let bounds = view.window?.bounds ?? UIScreen.main.bounds
        let dx = width / bounds.width
        let dy = height / bounds.height
        if min(dx, dy) < 1 {
            return 1 / min(dx, dy)
        } else {
            return view.window?.screen.scale ?? UIScreen.main.scale
        }
    }
    
}
