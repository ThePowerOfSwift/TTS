//
//  HistoryTreatmentSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class HistoryTreatmentItem: NSObject, ListDiffable {
    
    let id: String
    let masterPhoto: URL
    let master: String
    let date: String
    let order: String
    let reason: String
    let price: String?
    let didSelectItem: () -> Void
    
    let calculator: HistoryTreatmentCellLayoutCalculator
    
    private static var dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.locale = Locale.ru_RU
        result.dateStyle = .long
        result.timeStyle = .none
        return result
    }()
    
    private static var priceFormatter: BalanceFormatter = {
        let result = BalanceFormatter()
        result.locale = Locale.ru_RU
        return result
    }()
    
    init(treatment: Treatment, didSelectItem: @escaping () -> Void) {
        id = treatment.id
        masterPhoto = treatment.masterPhoto
        master = treatment.master
        date = type(of: self).dateFormatter.string(from: treatment.date)
        order = "№" + treatment.ordernum
        reason = treatment.reason
        price = type(of: self).priceFormatter.string(from: treatment.summ)
        self.didSelectItem = didSelectItem
        self.calculator = HistoryTreatmentCellLayoutCalculator(date: date, order: order, reason: reason)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(id)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? HistoryTreatmentItem else { return false }
        return id == object.id
            && masterPhoto == object.masterPhoto
            && master == object.master
            && date == object.date
            && order == object.order
            && reason == object.reason
    }
    
}

final class HistoryTreatmentSectionController: ListGenericSectionController<HistoryTreatmentItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: object.calculator.layout(for: collectionContext.containerSize.width).height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: HistoryTreatmentCell.self), bundle: nil, for: self, at: index) as? HistoryTreatmentCell else { fatalError() }
        cell.item = object
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        object?.didSelectItem()
    }
    
}
