//
//  AboutHeaderSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class AboutHeaderItem: NSObject, ListDiffable, HeightCalculatable {
    
    let bundleVersion: BundleVersion
    let height: CGFloat
    
    init(bundleVersion: BundleVersion, height: CGFloat) {
        self.bundleVersion = bundleVersion
        self.height = height
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? AboutHeaderItem else { return false }
        return bundleVersion == object.bundleVersion
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return height
    }
    
}

final class AboutHeaderSectionController: ListGenericSectionController<AboutHeaderItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: object.height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: AboutHeaderCell.self), bundle: nil, for: self, at: index) as? AboutHeaderCell else { fatalError() }
        cell.item = object
        return cell
    }
    
}
