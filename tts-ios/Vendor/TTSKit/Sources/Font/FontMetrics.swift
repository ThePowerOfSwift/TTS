//
//  FontMetrics.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 31/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public final class FontMetrics {
    
    public enum TextStyle {
        case body
        case callout
        case caption1
        case caption2
        case footnote
        case headline
        case subheadline
        case largeTitle
        case title1
        case title2
        case title3
        
        var textStyle: UIFont.TextStyle {
            switch self {
            case .body: return .body
            case .callout: return .callout
            case .caption1: return .caption1
            case .caption2: return .caption2
            case .footnote: return .footnote
            case .headline: return .headline
            case .subheadline: return .subheadline
            case .largeTitle:
                if #available(iOS 11.0, *) {
                    return .largeTitle
                } else {
                    return .title1
                }
            case .title1: return .title1
            case .title2: return .title2
            case .title3: return .title3
            }
        }
    }
    
    private let textStyle: TextStyle
    
    public static let `default` = FontMetrics(forTextStyle: .body)
    
    public init(forTextStyle textStyle: TextStyle) {
        self.textStyle = textStyle
    }
    
    public func scaledFont(for font: UIFont) -> UIFont {
        if #available(iOS 11.0, *) {
            return UIFontMetrics(forTextStyle: textStyle.textStyle).scaledFont(for: font)
        } else {
            return font
        }
    }
    
    public func scaledValue(for value: CGFloat) -> CGFloat {
        if #available(iOS 11.0, *) {
            return UIFontMetrics(forTextStyle: textStyle.textStyle).scaledValue(for: value)
        } else {
            return value
        }
    }
    
}
