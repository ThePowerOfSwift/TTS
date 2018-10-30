//
//  ServiceCentersListMyServicesSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ServiceCentersListMyServicesItem: NSObject, ListDiffable, HeightCalculatable {
    
    let pairs: [ServiceCenterUserAutoLightPair]
    let didSelect: (ServiceCenterUserAutoLightPair) -> Void
    let didConfigure: (ServiceCentersListMyServicesCell) -> Void

    init(pairs: [ServiceCenterUserAutoLightPair], didConfigure: @escaping (ServiceCentersListMyServicesCell) -> Void, didSelect: @escaping (ServiceCenterUserAutoLightPair) -> Void) {
        self.pairs = pairs
        self.didSelect = didSelect
        self.didConfigure = didConfigure
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ServiceCentersListMyServicesItem else { return false }
        return pairs == object.pairs
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return 148
    }
    
}

final class ServiceCentersListMyServicesSectionController: ListGenericSectionController<ServiceCentersListMyServicesItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ServiceCentersListMyServicesCell.self), bundle: nil, for: self, at: index) as? ServiceCentersListMyServicesCell else { fatalError() }
        cell.pairs = object?.pairs
        cell.didSelect = { [weak self] in
            self?.object?.didSelect($0)
        }
        object?.didConfigure(cell)
        return cell
    }
    
}
