//
//  PushStatus.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 27/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Статус push-уведомлений
public enum PushStatus: String, Codable {
    case disabled = "0"
    case enabled = "1"
}
