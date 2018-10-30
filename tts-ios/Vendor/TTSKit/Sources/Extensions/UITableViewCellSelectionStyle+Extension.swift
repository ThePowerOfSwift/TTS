//
//  UITableViewCellSelectionStyle+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit

extension UITableViewCell.SelectionStyle {
    
    public var color: UIColor? {
        switch self {
        case .default, .blue:
            return UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
        case .gray:
            return UIColor(white: 217/255.0, alpha: 1)
        case .none:
            return nil
        }
    }    
    
}
