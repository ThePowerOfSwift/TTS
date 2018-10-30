//
//  OrderTechServiceVariantSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class OrderTechServiceVariantItem: NSObject, ListDiffable, HeightCalculatable {
    
    let index: Int
    let variant: OrderTechServiceGetVariantsResponse.Variant
    let select: () -> Void
    var isSelected: Bool
    
    init(index: Int, variant: OrderTechServiceGetVariantsResponse.Variant, isSelected: Bool, select: @escaping () -> Void) {
        self.index = index
        self.variant = variant
        self.isSelected = isSelected
        self.select = select
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(String(describing: variant))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? OrderTechServiceVariantItem else { return false }
        return index == object.index && variant == object.variant && isSelected == object.isSelected
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return 180
    }
    
}

final class OrderTechServiceVariantSectionController: ListGenericSectionController<OrderTechServiceVariantItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object?.height(forWidth: width) ?? 0
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: OrderTechServiceVariantCell.self), bundle: nil, for: self, at: index) as? OrderTechServiceVariantCell else { fatalError() }
        cell.item = object
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        object?.select()
    }
    
}
