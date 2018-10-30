//
//  IndexPathsSelectableContainer.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

public protocol IndexPathsSelectionContainer {
    
    var selectedIndexPaths: [IndexPath]? { get }
    
    func select(indexPath: IndexPath, animated: Bool)
    
    func deselect(indexPath: IndexPath, animated: Bool)
    
    func deselectAll(animated: Bool)
    
}

extension IndexPathsSelectionContainer {
    
    public func deselectAll(animated: Bool) {
        selectedIndexPaths?.forEach({ deselect(indexPath: $0, animated: animated) })
    }
    
}

extension UITableView: IndexPathsSelectionContainer {
    
    public var selectedIndexPaths: [IndexPath]? {
        return indexPathsForSelectedRows
    }
    
    public func select(indexPath: IndexPath, animated: Bool) {
        selectRow(at: indexPath, animated: animated, scrollPosition: .none)
    }
    
    public func deselect(indexPath: IndexPath, animated: Bool) {
        deselectRow(at: indexPath, animated: animated)
    }
    
}

extension UICollectionView: IndexPathsSelectionContainer {
    
    public var selectedIndexPaths: [IndexPath]? {
        return indexPathsForSelectedItems
    }
    
    public func select(indexPath: IndexPath, animated: Bool) {
        selectItem(at: indexPath, animated: animated, scrollPosition: [])
    }
    
    public func deselect(indexPath: IndexPath, animated: Bool) {
        deselectItem(at: indexPath, animated: animated)
    }
    
}
