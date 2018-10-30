//
//  ServiceCentersListHeaderSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 17/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ServiceCentersListHeaderItem: NSObject, ListDiffable, HeightCalculatable {
    
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(text)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ServiceCentersListHeaderItem else { return false }
        return text == object.text
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return 40
    }
    
}

final class ServiceCentersListHeaderSectionController: ListGenericSectionController<ServiceCentersListHeaderItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ServiceCentersListHeaderCell.self), bundle: nil, for: self, at: index) as? ServiceCentersListHeaderCell else { fatalError() }
        cell.text = object?.text
        return cell
    }
    
}
