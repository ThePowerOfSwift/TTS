//
//  ListSwitchCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 30/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class ListSwitchCell: TableViewCollectionViewCell {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet var switchControl: UISwitch!
    @IBOutlet private var titleLabelLeadingSpace: NSLayoutConstraint!
    
    var item: ListSwitchItem? {
        didSet {
            imageView.image = item?.image
            titleLabel.text = item?.title
            switchControl.isOn = item?.isOn ?? false
            separatorInset = item?.separatorInset ?? TableViewCollectionViewCellAutomaticSeparatorInset
            
            if imageView.image == nil {
                titleLabelLeadingSpace.constant = max(16, separatorInset.left)
            } else {
                titleLabelLeadingSpace.constant = 52
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        separatorColor = UIColor(r: 57, g: 65, b: 88)
    }
    
    @IBAction
    private func switchControlValueChanged(sender: UISwitch) {
        guard let item = item else { return }
        if !item.shouldChangeSwitchControlValue(sender.isOn) {
            /// Calling setOn(_:animated:) when previous animation is in progress leads to ValueChanged event being triggering twice.
            /// And as a result of duplicated ValueChanged event isOn property does not reverts its value.
            /// To fix this, setOn(_:animated:) has to be scheduled to run on next iteration of the runloop.
            DispatchQueue.main.async {
                sender.setOn(!sender.isOn, animated: IsAnimationAllowed())
            }
        }
    }
    
}
