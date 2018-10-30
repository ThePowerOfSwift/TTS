//
//  ServiceCentersGroupSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 05/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

final class ServiceCentersGroupItem: NSObject, ListDiffable, HeightCalculatable, GMUClusterItem {
    
    var position: CLLocationCoordinate2D {
        return group.coordinate
    }
    
    let group: ServiceCenterGroup
    let separatorStyle: UITableViewCell.SeparatorStyle
    let background: BezierPathImage?
    
    init(group: ServiceCenterGroup, background: BezierPathImage? = nil, separatorStyle: UITableViewCell.SeparatorStyle = .none) {
        self.group = group
        self.background = background
        self.separatorStyle = separatorStyle
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))-\(group.coordinate)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? ServiceCentersGroupItem else { return false }
        return group == object.group
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return 48
    }
    
}

final class ServiceCentersGroupSectionController: ListGenericSectionController<ServiceCentersGroupItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = object else { return .zero }
        let width = collectionContext.containerSize.width
        let height = object.height(forWidth: width)
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: ServiceCentersGroupCell.self), bundle: nil, for: self, at: index) as? ServiceCentersGroupCell else { fatalError() }
        cell.item = object
        return cell
    }
    
}
