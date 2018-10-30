//
//  SessionStorage.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

private let kSessionCredentialAccountName = "session_credential"

public final class SessionStorage {
    
    let keychain: Keychain
    
    public init(keychain: Keychain) {
        self.keychain = keychain
    }
    
    public func save(_ value: SessionCredential?) throws {
        let attributes = Keychain.Attributes.genericPasswordItem(forAccount: kSessionCredentialAccountName)

        if let value = value {
            let acl = Keychain.AccessControl(protection: .whenUnlockedThisDeviceOnly)
            let data = try JSONEncoder().encode(value)
            try keychain.setData(data, attributes: attributes, acl: acl)
        } else {
            try keychain.deleteData(attributes: attributes)
        }
    }
    
    public func credential() throws -> SessionCredential {
        let attributes = Keychain.Attributes.genericPasswordItem(forAccount: kSessionCredentialAccountName)
        let data = try keychain.data(attributes: attributes)
        return try JSONDecoder().decode(SessionCredential.self, from: data)
    }
    
}
