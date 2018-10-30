//
//  ProfileUserInfoSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class ProfileUserInfoItem: NSObject, ListDiffable {
    
    let name: String?
    let bonuses: NSDecimalNumber?
    let phone: PhoneNumber?
    let bonusButtonTapped: () -> Void
    
    init(name: String?, bonuses: NSDecimalNumber?, phone: PhoneNumber?, bonusButtonTapped: @escaping () -> Void) {
        self.name = name
        self.bonuses = bonuses
        self.phone = phone
        self.bonusButtonTapped = bonusButtonTapped
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(String(describing: name))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ProfileUserInfoItem else { return false }
        return phone == object.phone && bonuses == object.bonuses
    }
    
}

final class ProfileUserInfoSectionController: ListGenericSectionController<ProfileUserInfoItem>, ListScrollDelegate, ListDisplayDelegate {
    
    override init() {
        super.init()
        scrollDelegate = self
        displayDelegate = self
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: 242)
    }
    
    private var cell: ProfileUserInfoCell?
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ProfileUserInfoCell.self), bundle: nil, for: self, at: index) as? ProfileUserInfoCell else { fatalError() }
        cell.item = object
        cell.bonusButton.addTarget(self, action: #selector(bonusButtonTapped), for: .touchUpInside)
        self.cell = cell
        return cell
    }
    
    private func updateImageViewTopSpaceOffset() {
        cell?.imageViewTopSpaceOffset = contentOffset?.y ?? 0
    }
    
    @objc
    private func bonusButtonTapped() {
        object?.bonusButtonTapped()
    }
    
    // MARK: - Scrolling
    
    private var contentOffset: CGPoint?
    
    func listAdapter(_ listAdapter: ListAdapter, didScroll sectionController: ListSectionController) {
        contentOffset = listAdapter.collectionView?.contentOffset
        updateImageViewTopSpaceOffset()
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willBeginDragging sectionController: ListSectionController) {
        // do nothing
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDragging sectionController: ListSectionController, willDecelerate decelerate: Bool) {
        // do nothing
    }
    
    // MARK: - Displaying

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        contentOffset = listAdapter.collectionView?.contentOffset
        updateImageViewTopSpaceOffset()
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        // do nothing
    }

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        // do nothing
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        // do nothing
    }
    
}
