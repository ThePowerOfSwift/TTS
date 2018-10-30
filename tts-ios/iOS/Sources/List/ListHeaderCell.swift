//
//  ListHeaderCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

final class ListHeaderCell: TableViewCollectionViewCell, NibLoadable {
    
    @IBOutlet private var textLabel: UILabel!
    
    private static let font: UIFont = .systemFont(ofSize: 13)
    
    var item: ListHeaderItem? {
        didSet {
            textLabel.text = item?.text
            separatorStyle = item?.separatorStyle ?? .singleLine
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.preservesSuperviewLayoutMargins = preservesSuperviewLayoutMargins
        textLabel.font = FontMetrics.default.scaledFont(for: ListHeaderCell.font)
        selectionStyle = .none
        separatorInset = .zero
        separatorColor = UIColor(r: 57, g: 65, b: 88)
    }
    
    static func height(for item: ListHeaderItem, in collectionContext: ListCollectionContext) -> CGFloat {
        let width = collectionContext.insetContainerSize.width
        
        var height: CGFloat = 0
        if let text = item.text, text.count > 0 {
            height = text.with(StringAttributes {
                $0.font = FontMetrics.default.scaledFont(for: ListHeaderCell.font)
                ()
            }).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
        }
        
        return ceil(height) + 6 + 14
    }
    
}
