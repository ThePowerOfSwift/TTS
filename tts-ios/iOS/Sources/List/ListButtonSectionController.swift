//
//  ListButtonSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ListButtonItem: NSObject, ListDiffable {
    
    let id: String
    let config: ((ListButtonCell) -> Void)?
    let select: (() -> Void)?
    
    init(id: String, config: ((ListButtonCell) -> Void)?, select: (() -> Void)?) {
        self.id = id
        self.config = config
        self.select = select
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(id)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListButtonItem else { return false }
        return id == object.id
    }
    
}

final class ListButtonSectionController: ListGenericSectionController<ListButtonItem> {
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ListButtonCell.self), bundle: nil, for: self, at: index) as? ListButtonCell else { fatalError() }
        object?.config?(cell)
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: 48)
    }
    
    override func didSelectItem(at index: Int) {
        object?.select?()
    }
    
}
