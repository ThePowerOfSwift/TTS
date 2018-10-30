//
//  GarageMainCarSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class GarageMainCarItem: NSObject, ListDiffable, HeightCalculatable {
    
    let auto: UserAuto?
    let onService: (() -> Void)?
    let onRepair: (() -> Void)?
    let onPrice: (() -> Void)?
    let height: CGFloat
    
    init(auto: UserAuto?, proposedHeight: CGFloat, onService: (() -> Void)?, onRepair: (() -> Void)?, onPrice: (() -> Void)?) {
        self.auto = auto
        self.onService = onService
        self.onRepair = onRepair
        self.onPrice = onPrice
        height = max(250, proposedHeight)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(String(describing: auto?.id))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? GarageMainCarItem else { return false }
        return auto == object.auto
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return height
    }
    
}

final class GarageMainCarSectionController: ListGenericSectionController<GarageMainCarItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: object.height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: GarageMainCarCell.self), bundle: nil, for: self, at: index) as? GarageMainCarCell else { fatalError() }
        cell.item = object
        cell.priceButton.addTarget(self, action: #selector(priceButtonTapped), for: .touchUpInside)
        cell.serviceButton.addTarget(self, action: #selector(serviceButtonTapped), for: .touchUpInside)
        cell.repairButton.addTarget(self, action: #selector(repairButtonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc
    private func priceButtonTapped() {
        object?.onPrice?()
    }
    
    @objc
    private func serviceButtonTapped() {
        object?.onService?()
    }
    
    @objc
    private func repairButtonTapped() {
        object?.onRepair?()
    }
    
}
