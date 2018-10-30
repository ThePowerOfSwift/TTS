//
//  ListBasicCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

class ListBasicCell: TableViewCollectionViewCell, NibLoadable, HeightCalculatable {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var imageViewLeadingSpace: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!
    @IBOutlet private var detailLabelTopSpace: NSLayoutConstraint!
    @IBOutlet private var labelsContainerViewLeadingSpace: NSLayoutConstraint!
    @IBOutlet private var chevronImageView: UIImageView!
    
    var item: ListBasicItem? {
        didSet {
            // image
            if let image = item?.layout.image {
                switch image {
                case .image(let image):
                    imageView.image = image
                case .url(let url, let filter):
                    imageView.af_setImage(withURL: url, filter: filter)
                }
            } else {
                imageView.af_cancelImageRequest()
                imageView.image = nil
            }
            
            if let foregroundColor = item?.layout.title.flatMap({ $0.attributedString.length > 0 ? $0.attributedString.attributes.foregroundColor : nil }) {
                imageView.tintColor = foregroundColor
            }

            // title
            titleLabel.attributedText = item?.layout.title?.attributedString
            
            // chevron
            chevronImageView.isHidden = item?.layout.isChevronHidden ?? false
            
            // background
            apply(background: item?.layout.background)
            
            // detail
            if let detail = item?.layout.detail {
                detailLabel.attributedText = detail.attributedString
                detailLabelTopSpace.constant = 10
            } else {
                detailLabel.attributedText = nil
                detailLabelTopSpace.constant = 0
            }
            
            // separator
            let defailtSeparatorInsetLeft = TableViewCollectionViewCell.leadingSeparatorInset(forCell: self, separatorInset: TableViewCollectionViewCellAutomaticSeparatorInset)
            let separatorStyle = item?.layout.separatorStyle ?? .inset(.default)
            switch separatorStyle {
            case .none:
                self.separatorStyle = .none
            case .inset(let inset):
                switch inset {
                case .custom(let inset):
                    separatorInset = inset
                case .default:
                    separatorInset = UIEdgeInsets(top: 0, left: defailtSeparatorInsetLeft, bottom: 0, right: 0)
                }
            }
            
            imageViewLeadingSpace.constant = max(defailtSeparatorInsetLeft, separatorInset.left)
            
            // text leading space
            if let item = item, case ListBasicLayout.Space.custom(let space) = item.layout.labelsContainerViewLeadingSpace {
                labelsContainerViewLeadingSpace.constant = space
            } else {
                var space = max(defailtSeparatorInsetLeft, separatorInset.left)
                if let imageSize = item?.layout.image?.size {
                    space += imageSize.width + defailtSeparatorInsetLeft
                }
                labelsContainerViewLeadingSpace.constant = space
            }
            
            setNeedsLayout()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorColor = UIColor(r: 57, g: 65, b: 88)
        selectionStyle = .gray
    }
    
}
