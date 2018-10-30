//
//  ListBasicCellLayout.swift
//  tts
//
//  Created by Dmitry Nesterenko on 21/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import AlamofireImage

struct ListBasicLayout: Equatable {
    
    enum Image: Equatable {
        case image(UIImage)
        case url(URL, filter: (ImageFilter & Sizable)?)
        
        var size: CGSize? {
            switch self {
            case .image(let image):
                return image.size
            case .url(_, let filter):
                return filter?.size
            }
        }
        
        static func == (lhs: Image, rhs: Image) -> Bool {
            if case Image.image(let lhsImage) = lhs, case Image.image(let rhsImage) = rhs {
                return lhsImage == rhsImage
            } else if case Image.url(let lhsURL, let lhsFilter) = lhs, case Image.url(let rhsURL, let rhsFilter) = rhs {
                return lhsURL == rhsURL && lhsFilter?.identifier == rhsFilter?.identifier
            } else {
                return false
            }
        }
    }
    
    enum SeparatorStyle: Equatable {
        case none
        case inset(EdgeInsets)
        
        static func == (lhs: SeparatorStyle, rhs: SeparatorStyle) -> Bool {
            if case SeparatorStyle.none = lhs, case SeparatorStyle.none = rhs {
                return true
            } else if case SeparatorStyle.inset(let lhsInset) = lhs, case SeparatorStyle.inset(let rhsInset) = rhs {
                return lhsInset == rhsInset
            } else {
                return false
            }
        }
    }
    
    enum EdgeInsets: Equatable {
        case `default`
        case custom(UIEdgeInsets)
        
        static func == (lhs: EdgeInsets, rhs: EdgeInsets) -> Bool {
            if case EdgeInsets.default = lhs, case EdgeInsets.default = rhs {
                return true
            } else if case EdgeInsets.custom(let lhsInset) = lhs, case EdgeInsets.custom(let rhsInset) = rhs {
                return lhsInset == rhsInset
            } else {
                return false
            }
        }
    }
    
    enum Space: Equatable {
        case `default`
        case custom(CGFloat)
        
        static func == (lhs: Space, rhs: Space) -> Bool {
            if case Space.default = lhs, case Space.default = rhs {
                return true
            } else if case Space.custom(let lhsSpace) = lhs, case Space.custom(let rhsSpace) = rhs {
                return lhsSpace == rhsSpace
            } else {
                return false
            }
        }
    }
    
    struct Text: Equatable {
        
        var attributedString: NSAttributedString
        
        init(string: String, font: UIFont?, textColor: UIColor?) {
            attributedString = string.with(StringAttributes {
                $0.foregroundColor = textColor
                $0.font = font
            })
        }
        
        init(attributedString: NSAttributedString) {
            self.attributedString = attributedString
        }
        
        init(title string: String, font: UIFont? = .systemFont(ofSize: 17, weight: .light), textColor: UIColor? = .white) {
            self.init(string: string, font: font, textColor: textColor)
        }
        
        init(detail string: String, font: UIFont = .systemFont(ofSize: 15, weight: .light), textColor: UIColor = UIColor(white: 0.49, alpha: 1)) {
            self.init(string: string, font: font, textColor: textColor)
        }
        
    }
    
    var image: Image?
    
    var title: Text?

    var detail: Text?

    var detailLabelTopSpace: CGFloat = 10

    var labelsContainerViewLeadingSpace: Space

    var background: BezierPathImage?
    
    var separatorStyle: SeparatorStyle = .inset(.default)
    
    var isChevronHidden = false
    
    init(image: Image? = nil, title: Text?, detail: Text? = nil, labelsContainerViewLeadingSpace: Space = .default, background: BezierPathImage? = nil, separatorStyle: SeparatorStyle = .inset(.default), isChevronHidden: Bool = false) {
        self.image = image
        self.title = title
        self.detail = detail
        self.labelsContainerViewLeadingSpace = labelsContainerViewLeadingSpace
        self.background = background
        self.separatorStyle = separatorStyle
        self.isChevronHidden = isChevronHidden
    }
    
    init(parameterLayoutWithImage image: Image? = nil, title: String? = nil, detail: String? = nil) {
        self.image = image
        if let detail = detail {
            self.title = title.flatMap { Text(string: $0, font: .systemFont(ofSize: 15, weight: .light), textColor: UIColor(r: 128, g: 140, b: 153)) }
            self.detail = Text(string: detail, font: .systemFont(ofSize: 17, weight: .light), textColor: .white)
        } else {
            self.title = title.flatMap { Text(string: $0, font: .systemFont(ofSize: 17, weight: .light), textColor: .white) }
        }
        self.labelsContainerViewLeadingSpace = .default
        self.separatorStyle = SeparatorStyle.inset(.custom(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)))
        self.isChevronHidden = false
    }

}
