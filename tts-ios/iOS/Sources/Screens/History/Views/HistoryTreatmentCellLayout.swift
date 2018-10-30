//
//  HistoryTreatmentCellLayout.swift
//  tts
//
//  Created by Dmitry Nesterenko on 19/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

struct HistoryTreatmentCellLayout {
    
    var contentInset: UIEdgeInsets = .zero
    
    let textLabelsLeadingSpace: CGFloat = 72
    
    var dateLabelFrame: CGRect = .zero
    
    var orderLabelFrame: CGRect = .zero
    
    var reasonLabelFrame: CGRect = .zero
    
    var height: CGFloat {
        return reasonLabelFrame.maxY + contentInset.bottom
    }

}
