//
//  ListHeaderSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ListHeaderItem: NSObject, ListDiffable {
    
    let id: String
    let text: String?
    let separatorStyle: UITableViewCell.SeparatorStyle
    
    convenience init(text: String, separatorStyle: UITableViewCell.SeparatorStyle = .singleLine) {
        self.init(id: text, text: text, separatorStyle: separatorStyle)
    }
    
    init(id: String, text: String? = nil, separatorStyle: UITableViewCell.SeparatorStyle = .singleLine) {
        self.id = id
        self.text = text
        self.separatorStyle = separatorStyle
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(id)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListHeaderItem else { return false }
        return text == object.text && separatorStyle == object.separatorStyle
    }
    
}

final class ListHeaderSectionController: ListGenericSectionController<ListHeaderItem> {
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ListHeaderCell.self), bundle: nil, for: self, at: index) as? ListHeaderCell else { fatalError() }
        cell.item = object
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        
        let height: CGFloat
        if let object = object {
            height = ListHeaderCell.height(for: object, in: collectionContext)
        } else {
            height = 18
        }
        
        return CGSize(width: collectionContext.containerSize.width, height: height)
    }
    
}
