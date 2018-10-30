//
//  GarageMainAddUserAutoSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit

final class GarageMainAddUserAutoItem: NSObject, ListDiffable, HeightCalculatable {
    
    let buttonTapped: () -> Void
    
    init(buttonTapped: @escaping () -> Void) {
        self.buttonTapped = buttonTapped
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? GarageMainAddUserAutoItem else { return false }
        return self == object
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return 115
    }
    
}

final class GarageMainAddUserAutoSectionController: ListGenericSectionController<GarageMainAddUserAutoItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: GarageMainAddUserAutoCell.self), bundle: nil, for: self, at: index) as? GarageMainAddUserAutoCell else { fatalError() }
        cell.button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc
    private func buttonTapped() {
        object?.buttonTapped()
    }
    
}
