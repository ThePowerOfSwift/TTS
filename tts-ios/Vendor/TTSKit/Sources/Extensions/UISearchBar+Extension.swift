//
//  UISearchBar+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    /// Accessor method for embedded text field
    public var textField: UITextField? {
        guard let textField = value(forKey: "searchField") as? UITextField else {
            return subviews.flatMap { $0.subviews }.first(where: { $0 is UITextField }) as? UITextField
        }
        
        return textField
    }
    
}
