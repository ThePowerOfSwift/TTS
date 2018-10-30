//
//  ListSwitchSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 30/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ListSwitchItem: NSObject, ListDiffable {
    
    let title: String
    let image: UIImage?
    let isOn: Bool
    let separatorInset: UIEdgeInsets
    let shouldChangeSwitchControlValue: (Bool) -> Bool
    
    init(title: String, image: UIImage? = nil, isOn: Bool, separatorInset: UIEdgeInsets = TableViewCollectionViewCellAutomaticSeparatorInset, shouldChangeSwitchControlValue: @escaping (Bool) -> Bool) {
        self.title = title
        self.image = image
        self.isOn = isOn
        self.separatorInset = separatorInset
        self.shouldChangeSwitchControlValue = shouldChangeSwitchControlValue
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(title)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ListSwitchItem else { return false }
        return image == object.image && isOn == object.isOn
    }
    
}

final class ListSwitchSectionController: ListGenericSectionController<ListSwitchItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: 52)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ListSwitchCell.self), bundle: nil, for: self, at: index) as? ListSwitchCell else { fatalError() }
        cell.item = object
        return cell
    }
    
}
