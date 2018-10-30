//
//  GarageAutoInfoViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

final class GarageAutoInfoViewController: UIViewController, ErrorPresenting {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var numberPlateNumberLabel: UILabel!
    @IBOutlet private var numberPlateRegionLabel: UILabel!
    @IBOutlet private var vinLabel: UILabel!
    @IBOutlet private var configurationLabel: UILabel!
    @IBOutlet private var yearLabel: UILabel!
    @IBOutlet private var archiveButton: GarageAutoArchiveButton!
    
    private let interactor: GarageAutoInfoInteractor
    private let archived: () -> Void
    
    // MARK: - Initialization
    
    private var transition = DimmingTransition()
    
    init(interactor: GarageAutoInfoInteractor, archived: @escaping () -> Void) {
        self.interactor = interactor
        self.archived = archived
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = transition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView(withAuto: nil)
        interactor.observeData { [weak self] in
            self?.configureView(withAuto: $0)
        }
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    private func updatePreferredContentSize() {
        preferredContentSize = CGSize(width: view.bounds.width, height: archiveButton.frame.maxY)
    }
    
    // MARK: - Actions
    
    @IBAction
    private func closeButtonTapped() {
        dismiss(animated: IsAnimationAllowed(), completion: nil)
    }
    
    // MARK: - Archiving
    
    private func setArchiving(_ archiving: Bool) {
        archiveButton.isEnabled = !archiving
        archiving ? archiveButton.startAnimating() : archiveButton.stopAnimating()
    }
    
    @IBAction
    private func archiveButtonTapped() {
        setArchiving(true)
        interactor.archive(onArchive: { [weak self] in
            self?.interactor.stopObservingData()
        }, onError: { [weak self] in
            self?.setArchiving(false)
            self?.showError($0)
        }, onCompleted: { [weak self] in
            self?.setArchiving(false)
            self?.archived()
        })
    }
    
    // MARK: - User Auto
    
    private func configureView(withAuto auto: UserAuto?) {
        titleLabel.text = auto?.brand
        
        if let url = auto?.image {
            imageView.af_setImage(withURL: url, filter: AspectScaledToFitSizeFilter(size: CGSize(width: 110, height: 80)))
        } else {
            imageView.af_cancelImageRequest()
            imageView.image = nil
        }
        
        if let plateNumber = auto?.gosnomer {
            // apply small caps feature to plate number text
            // see https://liamnichols.github.io/2016/09/11/using-small-caps-in-uikit.html
            let smallCapsFontAttributes: [UIFontDescriptor.AttributeName: Any] = [.featureSettings: [
                [UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType, UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector]
                ]
            ]
            
            let letters = StringAttributes {
                $0.font = UIFont.boldSystemFont(ofSize: 20).addingAttributes(smallCapsFontAttributes)
                $0.foregroundColor = numberPlateNumberLabel.textColor
            }
            let numbers = StringAttributes {
                $0.font = UIFont.boldSystemFont(ofSize: 28).addingAttributes(smallCapsFontAttributes)
                $0.foregroundColor = numberPlateNumberLabel.textColor
            }
            numberPlateNumberLabel.attributedText = PlateNumberFormatter().numberAttributedString(for: plateNumber, lettersAttributes: letters, numbersAttributes: numbers)
            numberPlateRegionLabel.text = plateNumber.region
        } else {
            numberPlateNumberLabel.attributedText = nil
            numberPlateRegionLabel.text = nil
        }
        
        vinLabel.text = auto?.vin
        
        configurationLabel.text = auto.flatMap {
            let numberOfCharacters = $0.complectation?.count ?? 0
            return numberOfCharacters > 0 ? $0.complectation : $0.model
        }
        
        yearLabel.text = auto.flatMap {String($0.year)}
        
        updatePreferredContentSize()
    }
    
}
