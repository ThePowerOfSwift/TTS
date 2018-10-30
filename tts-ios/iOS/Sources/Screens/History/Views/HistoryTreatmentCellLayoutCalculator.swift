//
//  HistoryTreatmentCellLayoutCalculator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 19/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

private let kDateLabelTopSpace: CGFloat = 16
private let kTextLabelsVerticalSpace: CGFloat = 8
private let kTextLabelsTrailingSpace: CGFloat = 16

final class HistoryTreatmentCellLayoutCalculator {
    
    private let date: String
    private let order: String
    private let reason: String
    let dateLabelFont = UIFont.systemFont(ofSize: 15, weight: .light)
    let orderLabelFont = UIFont.systemFont(ofSize: 13, weight: .light)
    let reasonLabelFont = UIFont.systemFont(ofSize: 13, weight: .light)
    
    init(date: String, order: String, reason: String) {
        self.date = date
        self.order = order
        self.reason = reason
    }
    
    // MARK: - Laying Out
    
    private var cache = [CGFloat: HistoryTreatmentCellLayout]()
    
    func setNeedsLayout() {
        cache.removeAll()
    }
    
    func layout(for width: CGFloat) -> HistoryTreatmentCellLayout {
        if let layout = cache[width] {
            return layout
        }
        
        var layout = HistoryTreatmentCellLayout()
        layout.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let textLabelsMaxWidth = width - layout.textLabelsLeadingSpace - layout.contentInset.right
        let textLabelsProposedSize = CGSize(width: textLabelsMaxWidth, height: CGFloat.greatestFiniteMagnitude)
            
        // date label frame
        do {
            let boundingRect = date.with(StringAttributes {
                $0.font = dateLabelFont
                ()
            }).boundingRect(with: textLabelsProposedSize, options: [], context: nil)
            layout.dateLabelFrame = CGRect(x: 0, y: layout.contentInset.top, width: ceil(boundingRect.width), height: ceil(boundingRect.height))
        }
        
        // order label frame
        do {
            let boundingRect = order.with(StringAttributes {
                $0.font = orderLabelFont
                ()
            }).boundingRect(with: textLabelsProposedSize, options: [], context: nil)
            layout.orderLabelFrame = CGRect(x: 0, y: layout.dateLabelFrame.maxY + kTextLabelsVerticalSpace, width: ceil(boundingRect.width), height: ceil(boundingRect.height))
        }
        
        // reason label frame
        do {
            let boundingRect = reason.with(StringAttributes {
                $0.font = reasonLabelFont
                ()
            }).boundingRect(with: textLabelsProposedSize, options: .usesLineFragmentOrigin, context: nil)
            layout.reasonLabelFrame = CGRect(x: 0, y: layout.orderLabelFrame.maxY + kTextLabelsVerticalSpace, width: ceil(boundingRect.width), height: ceil(boundingRect.height))
        }
        
        // cache
        cache[width] = layout
        return layout
    }
    
}
