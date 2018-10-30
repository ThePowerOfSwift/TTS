//
//  FetchedResultsObservable.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

final class FetchedResultsControllerDelegate<T: NSFetchRequestResult> : NSObject, NSFetchedResultsControllerDelegate {
    
    var subject = BehaviorSubject<[T]>(value: [])
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects as? [T] else { return }
        subject.onNext(fetchedObjects)
    }
    
}

public final class FetchedResultsObservable<T: NSFetchRequestResult> : ObservableType {
    
    public typealias E = [T]
    
    let fetchRequest: NSFetchRequest<T>
    let managedObjectContext: NSManagedObjectContext
    let sectionNameKeyPath: String?
    let cacheName: String?
    
    weak var delegate: FetchedResultsControllerDelegate<T>?
    weak var frc: NSFetchedResultsController<T>?
    
    public init(fetchRequest: NSFetchRequest<T>, managedObjectContext: NSManagedObjectContext, sectionNameKeyPath: String? = nil, cacheName: String? = nil) {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.sectionNameKeyPath = sectionNameKeyPath
        self.cacheName = cacheName
    }
    
    public func subscribe<O>(_ observer: O) -> Disposable where O: ObserverType, FetchedResultsObservable.E == O.E {
        var delegate: FetchedResultsControllerDelegate<T>? = FetchedResultsControllerDelegate<T>()
        var frc: NSFetchedResultsController<T>? = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        frc?.delegate = delegate
        
        // save frc and delegate for unit tests
        self.delegate = delegate
        self.frc = frc
        
        // fetch
        do {
            try frc?.performFetch()
        } catch {
            observer.onError(error)
            return Disposables.create()
        }
        
        // init subject with fetched objects
        delegate?.subject = BehaviorSubject(value: frc?.fetchedObjects ?? [])
        
        // observing
        let subscription = delegate!.subject.subscribe(onNext: { result in
            observer.onNext(result)
        })
        
        // disposing
        let disposable = Disposables.create {
            delegate = nil
            frc = nil
        }
        
        return Disposables.create(subscription, disposable)
    }
    
}
