//
//  GarageMainTechServiceRecordSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class GarageMainTechServiceRecordItem: NSObject, ListDiffable, HeightCalculatable {
    
    let record: TechServiceRecord
    let backgroundColor: UIColor?
    let cardColor = UIColor(r: 0, g: 148, b: 213)
    let select: () -> Void
    
    init(record: TechServiceRecord, backgroundColor: UIColor?, select: @escaping () -> Void) {
        self.record = record
        self.backgroundColor = backgroundColor
        self.select = select
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(record.id)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? GarageMainTechServiceRecordItem else { return false }
        return record == object.record
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        guard let cell = GarageMainTechServiceRecordCell.loadFromNib() else { return 0 }
        cell.item = self
        return cell.height(forWidth: width)
    }
    
}

final class GarageMainTechServiceRecordSectionController: ListGenericSectionController<GarageMainTechServiceRecordItem> {
    
    private static let heightForItem: CGFloat = 44
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: GarageMainTechServiceRecordCell.self), bundle: nil, for: self, at: index) as? GarageMainTechServiceRecordCell else { fatalError() }
        cell.item = object
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        object?.select()
    }
    
}
