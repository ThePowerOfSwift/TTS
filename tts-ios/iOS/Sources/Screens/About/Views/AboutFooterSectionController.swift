//
//  AboutFooterSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class AboutFooterItem: NSObject, ListDiffable, HeightCalculatable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard object is AboutFooterItem else { return false }
        return true
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return 110
    }
    
}

final class AboutFooterSectionController: ListGenericSectionController<AboutFooterItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: AboutFooterCell.self), bundle: nil, for: self, at: index) as? AboutFooterCell else { fatalError() }
        cell.item = object
        return cell
    }
    
}
