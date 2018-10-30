//
//  UserAutoTileSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 13/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

private let kSizeRatio: CGFloat = 148 / 188.0

final class UserAutoTileItem: NSObject, ListDiffable {
    
    let auto: UserAuto
    let didSelect: (UserAuto) -> Void
    
    init(auto: UserAuto, didSelect: @escaping (UserAuto) -> Void) {
        self.auto = auto
        self.didSelect = didSelect
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(auto.id)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? UserAutoTileItem else { return false }
        return self.auto == object.auto
    }
    
}

final class UserAutoTileSectionController: ListGenericSectionController<UserAutoTileItem> {
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        let width = ceil((collectionContext.containerSize.width - collectionContext.containerInset.left - collectionContext.containerInset.right) / 2 - inset.left - inset.right)
        let height = round(width / kSizeRatio)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: UserAutoTileCell.self), bundle: nil, for: self, at: index) as? UserAutoTileCell else { fatalError() }
        cell.item = object
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        guard let auto = object?.auto else { return }
        object?.didSelect(auto)
    }
    
}
