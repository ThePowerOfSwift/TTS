//
//  OrderTechServiceProposeSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class OrderTechServiceProposeItem: NSObject, ListDiffable, HeightCalculatable {
    
    let title: String?
    let subtitle: String?
    let rightDetailTitle: String?
    
    init(title: String?, subtitle: String?, rightDetailTitle: String?) {
        self.title = title
        self.subtitle = subtitle
        self.rightDetailTitle = rightDetailTitle
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(String(describing: title))-\(String(describing: subtitle))-\(String(describing: rightDetailTitle))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? OrderTechServiceProposeItem else { return false }
        return title == object.title && subtitle == object.subtitle && rightDetailTitle == object.rightDetailTitle
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        guard let cell = OrderTechServiceProposeCell.loadFromNib() else { return 0 }
        cell.item = self
        return cell.height(forWidth: width)
    }
    
}

final class OrderTechServiceProposeSectionController: ListGenericSectionController<OrderTechServiceProposeItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object?.height(forWidth: width) ?? 0
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: OrderTechServiceProposeCell.self), bundle: nil, for: self, at: index) as? OrderTechServiceProposeCell else { fatalError() }
        cell.item = object
        return cell
    }
    
}
