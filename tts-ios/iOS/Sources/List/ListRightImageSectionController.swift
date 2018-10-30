//
//  ListRightImageSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ListRightImageItem: NSObject, ListDiffable, HeightCalculatable {
    
    let text: String
    let image: UIImage
    let textColor: UIColor?
    let font: UIFont
    let backgroundColor: UIColor?
    let selected: () -> Void
    
    init(text: String, image: UIImage, textColor: UIColor, font: UIFont = .systemFont(ofSize: 17), backgroundColor: UIColor? = nil, selected: @escaping () -> Void) {
        self.image = image
        self.text = text
        self.textColor = textColor
        self.font = font
        self.backgroundColor = backgroundColor
        self.selected = selected
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(text)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListRightImageItem else { return false }
        return image == object.image && textColor == object.backgroundColor && backgroundColor == object.backgroundColor
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return 52
    }
    
}

final class ListRightImageSectionController: ListGenericSectionController<ListRightImageItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ListRightImageCell.self), bundle: nil, for: self, at: index) as? ListRightImageCell else { fatalError() }
        cell.item = object
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        object?.selected()
    }
    
}
