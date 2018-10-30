//
//  HistoryDetailsArrangedSubviewsBuilder.swift
//  tts
//
//  Created by Dmitry Nesterenko on 22/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

private let kContentViewBackgroundColor = UIColor(r: 45, g: 52, b: 69)

final class HistoryDetailsArrangedSubviewsBuilder {
    
    enum Style {
        case header
        case detail
        case total
    }
    
    private var subviews = [UIView]()
    private let stackView: UIStackView
    
    init(stackView: UIStackView) {
        self.stackView = stackView
    }
    
    private func addArrangedSubview(title: String, detail: String?, style: Style, corners: UIRectCorner = []) {
        let containerHeight: CGFloat = 56
        let textLabelColor: UIColor
        let textLabelFont: UIFont
        let detailLabelFont: UIFont
        
        switch style {
        case .header:
            textLabelColor = UIColor(r: 112, g: 124, b: 137)
            textLabelFont = UIFont.systemFont(ofSize: 15, weight: .light)
            detailLabelFont = textLabelFont
        case .detail:
            textLabelColor = .white
            textLabelFont = UIFont.systemFont(ofSize: 15, weight: .light)
            detailLabelFont = textLabelFont
        case .total:
            textLabelColor = .white
            textLabelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            detailLabelFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: stackView.bounds.width, height: containerHeight))
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let content = UIView(frame: container.bounds.insetBy(dx: 8, dy: 0))
        content.autoresizingMask = .flexibleDimensions
        let contentBackgroundColor = kContentViewBackgroundColor
        if corners.rawValue == 0 {
            content.backgroundColor = contentBackgroundColor
        } else {
            let imageView = UIImageView(frame: content.bounds)
            imageView.autoresizingMask = .flexibleDimensions
            
            let radius: CGFloat = 4
            let drawable = BezierPathImage(fillColor: contentBackgroundColor, corners: corners, radius: radius)
            let image = ImageDrawer.default.draw(drawable, in: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
            imageView.image = image.resizableImage(withCapInsets: UIEdgeInsets(top: radius, left: radius, bottom: radius, right: radius))
            content.addSubview(imageView)
        }
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = textLabelFont
        titleLabel.text = title
        titleLabel.textColor = textLabelColor
        titleLabel.sizeToFit()
        
        let detailLabel = UILabel()
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = detailLabelFont
        detailLabel.text = detail
        detailLabel.textColor = textLabelColor
        detailLabel.sizeToFit()
        
        container.addSubview(content)
        content.addSubview(titleLabel)
        content.addSubview(detailLabel)
        stackView.addArrangedSubview(container)
        subviews.append(container)
        
        let views = ["title": titleLabel, "detail": detailLabel]
        content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[title]-(>=12)-[detail]-(8)-|", options: [], metrics: nil, views: views))
        titleLabel.centerYAnchor.constraint(equalTo: content.centerYAnchor).isActive = true
        detailLabel.centerYAnchor.constraint(equalTo: content.centerYAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: containerHeight).isActive = true
    }

    func addHeaderSubview(title: String, detail: String) {
        let corners: UIRectCorner = subviews.count == 0 ? [.topLeft, .topRight] : []
        addArrangedSubview(title: title, detail: detail, style: .header, corners: corners)
    }

    func addDetailSubview(title: String, detail: String?) {
        let corners: UIRectCorner = subviews.count == 0 ? [.topLeft, .topRight] : []
        addArrangedSubview(title: title, detail: detail, style: .detail, corners: corners)
    }

    func addTotalSubview(detail: String?) {
        addArrangedSubview(title: "Итого", detail: detail, style: .total, corners: [.bottomLeft, .bottomLeft])
    }
    
    func addSeparatorSubview() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: stackView.bounds.width, height: 1))
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let content = UIView(frame: container.bounds.insetBy(dx: 8, dy: 0))
        content.autoresizingMask = .flexibleDimensions
        content.backgroundColor = kContentViewBackgroundColor
        
        let separatorView = SeparatorView(frame: content.bounds.insetBy(dx: 8, dy: 0))
        separatorView.backgroundColor = UIColor(r: 56, g: 65, b: 88)
        separatorView.autoresizingMask = .flexibleDimensions
        
        container.addSubview(content)
        content.addSubview(separatorView)
        stackView.addArrangedSubview(container)
        subviews.append(container)
        
        container.heightAnchor.constraint(equalToConstant: separatorView.intrinsicContentSize.height).isActive = true
    }
    
    func addSpacerSubview(height: CGFloat) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: stackView.bounds.width, height: height))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: height).isActive = true
        stackView.addArrangedSubview(container)
        subviews.append(container)
    }

    func removeSubviewsFromSuperview() {
        subviews.forEach {$0.removeFromSuperview()}
        subviews.removeAll()
    }
    
}
