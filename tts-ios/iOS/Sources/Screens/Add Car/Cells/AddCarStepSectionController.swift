//
//  AddCarStepSectionController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import IGListKit
import TTSKit

final class AddCarStepItem: NSObject, ListDiffable {
    
    let currentStep: Int
    let maxSteps: Int
    
    init(currentStep: Int, maxSteps: Int) {
        self.currentStep = currentStep
        self.maxSteps = maxSteps
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(String(describing: type(of: self)))" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? AddCarStepItem else { return false }
        return currentStep == object.currentStep && maxSteps == object.maxSteps
    }
    
}

final class AddCarStepSectionController: ListGenericSectionController<AddCarStepItem> {
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { return .zero }
        return CGSize(width: collectionContext.containerSize.width, height: 48)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: String(describing: AddCarStepCell.self), bundle: nil, for: self, at: index) as? AddCarStepCell else { fatalError() }
        cell.item = object
        return cell
    }
    
}
