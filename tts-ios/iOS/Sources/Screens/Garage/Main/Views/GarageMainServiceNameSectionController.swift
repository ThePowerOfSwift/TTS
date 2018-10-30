//
//  GarageMainServiceNameSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class GarageMainServiceNameItem: NSObject, ListDiffable, HeightCalculatable {
    
    let name: String
    let backgroundColor: UIColor?
    let cardColor = UIColor(r: 37, g: 42, b: 57)
    
    static func hotLineItem(backgroundColor: UIColor?) -> GarageMainServiceNameItem {
        return GarageMainServiceNameItem(name: "Горячая линия", backgroundColor: backgroundColor)
    }
    
    init(name: String, backgroundColor: UIColor?) {
        self.name = name
        self.backgroundColor = backgroundColor
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(name)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? GarageMainServiceNameItem else { return false }
        return name == object.name && backgroundColor == object.backgroundColor
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        guard let cell = GarageMainServiceNameCell.loadFromNib() else { return 0 }
        cell.item = self
        return cell.height(forWidth: width)
    }
    
}

final class GarageMainServiceNameSectionController: ListGenericSectionController<GarageMainServiceNameItem> {
    
    private static let heightForItem: CGFloat = 44
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: GarageMainServiceNameCell.self), bundle: nil, for: self, at: index) as? GarageMainServiceNameCell else { fatalError() }
        cell.item = object
        return cell
    }
    
}
