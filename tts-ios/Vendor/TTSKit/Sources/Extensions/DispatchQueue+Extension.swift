//
//  DispatchQueue+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 10/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    
    /// Work that operates in the background and isn’t visible to the user, such as indexing, synchronizing, and backups. Focuses on energy efficiency.
    ///
    /// Work takes significant time, such as minutes or hours.
    public static let background      = DispatchQueue.global(qos: .background)
    
    /// Work that may take some time to complete and doesn’t require an immediate result, such as downloading or importing data. Utility tasks typically have a progress bar that is visible to the user. Focuses on providing a balance between responsiveness, performance, and energy efficiency.
    ///
    /// Work takes a few seconds to a few minutes.
    public static let utility         = DispatchQueue.global(qos: .utility)
    
    /// The priority level of this QoS falls between user-initiated and utility. This QoS is not intended to be used by developers to classify work. Work that has no QoS information assigned is treated as default, and the GCD global queue runs at this level.
    public static let `default`       = DispatchQueue.global(qos: .default)
    
    /// Work that the user has initiated and requires immediate results, such as opening a saved document or performing an action when the user clicks something in the user interface. The work is required in order to continue user interaction. Focuses on responsiveness and performance.
    ///
    /// Work is nearly instantaneous, such as a few seconds or less.
    public static let userInitiated   = DispatchQueue.global(qos: .userInitiated)
    
    /// Work that is interacting with the user, such as operating on the main thread, refreshing the user interface, or performing animations. If the work doesn’t happen quickly, the user interface may appear frozen. Focuses on responsiveness and performance.
    ///
    /// Work is virtually instantaneous.
    public static let userInteractive = DispatchQueue.global(qos: .userInteractive)
    
    /// This represents the absence of QoS information and cues the system that an environmental QoS should be inferred. Threads can have an unspecified QoS if they use legacy APIs that may opt the thread out of QoS.
    public static let unspecified     = DispatchQueue.global(qos: .unspecified)
    
    public func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
    
}
