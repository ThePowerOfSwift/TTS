//
//  ServiceCentersListServiceSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 17/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ServiceCentersListServiceItem: NSObject, ListDiffable, HeightCalculatable {
    
    var height: CGFloat
    
    let image: URL?
    let address: String?
    let brands: [URL]
    let didSelect: () -> Void
    
    init(group: ServiceCenterGroup, didSelect: @escaping (ServiceCenterGroup) -> Void) {
        self.image = group.services.first?.image
        self.address = group.address
        self.brands = group.services.compactMap({$0.brandImage})
        self.didSelect = {
            didSelect(group)
        }
        self.height = group.services.count > 0 ? 64 + 48 : 64
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(String(describing: image))-\(String(describing: address))-\(String(describing: brands))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ServiceCentersListServiceItem else { return false }
        return image == object.image && address == object.address && brands == object.brands
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return height 
    }
    
}

final class ServiceCentersListServiceSectionController: ListGenericSectionController<ServiceCentersListServiceItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: object.height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ServiceCentersListServiceCell.self), bundle: nil, for: self, at: index) as? ServiceCentersListServiceCell else { fatalError() }
        cell.setImage(object?.image, address: object?.address, brands: object?.brands)
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        object?.didSelect()
        
    }
    
}
