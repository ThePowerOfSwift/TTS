//
//  AddCarStepCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

final class AddCarStepCell: TableViewCollectionViewCell {

    @IBOutlet private var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        separatorStyle = .none
    }
    
    var item: AddCarStepItem? {
        didSet {
            textLabel.text = item.flatMap { "Шаг \($0.currentStep) из \($0.maxSteps)" }
        }
    }
    
}
