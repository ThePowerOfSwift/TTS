//
//  ListTextFieldSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ListTextFieldItem: NSObject, ListDiffable, HeightCalculatable {
    
    let id: String
    let height: CGFloat
    let config: ((ListTextFieldCell) -> Void)?
    
    init(id: String, height: CGFloat = 60, config: ((ListTextFieldCell) -> Void)?) {
        self.id = id
        self.height = height
        self.config = config
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(String(describing: id))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListTextFieldItem else { return false }
        return id == object.id
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return height
    }
    
}

final class ListTextFieldSectionController: ListGenericSectionController<ListTextFieldItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ListTextFieldCell.self), bundle: nil, for: self, at: index) as? ListTextFieldCell else { fatalError() }
        object?.config?(cell)
        return cell
    }
    
}
