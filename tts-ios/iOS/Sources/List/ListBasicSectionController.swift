//
//  ListBasicSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ListBasicItem: NSObject, ListDiffable, HeightCalculatable {
    
    let id: String?
    let layout: ListBasicLayout
    let selected: (() -> Void)?
    let minHeight: CGFloat
    
    init(id: String? = nil, layout: ListBasicLayout, minHeight: CGFloat = 52, selected: (() -> Void)?) {
        self.id = id
        self.layout = layout
        self.minHeight = minHeight
        self.selected = selected
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(String(describing: id))-\(String(describing: layout.title?.attributedString))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListBasicItem else { return false }
        return id == object.id && layout == object.layout
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        guard let cell = ListBasicCell.loadFromNib() else { return 0 }
        cell.item = self
        return max(minHeight, cell.height(forWidth: width))
    }
    
}

final class ListBasicSectionController: ListGenericSectionController<ListBasicItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ListBasicCell.self), bundle: nil, for: self, at: index) as? ListBasicCell else { fatalError() }
        cell.item = object
        if object?.selected == nil {
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .gray
        }
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        object?.selected?()
    }
    
}
