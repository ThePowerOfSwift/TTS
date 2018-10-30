//
//  Crypto.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 10/09/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import CommonCrypto

/// AES implementation
///
/// - [Properly Encrypting With AES With CommonCrypto](http://robnapier.net/aes-commoncrypto)
public final class Crypto {
    
    enum Error: Swift.Error {
        case keyDerivationPBKDFFailed(status: Int32)
        case randomCopyBytesFailed(status: Int32)
        case cryptFailed(status: Int32)
    }
    
    public struct Info: Codable {
        let data: Data
        let iv: Data
        let salt: Data
    }
    
    private let blockSize: Int
    private let saltSize: Int
    
    /// Password-Based Key Derivation Function 2
    ///
    /// SHA-256 is not a secure password hashing algorithm
    ///
    /// PBKDF2 applies a pseudorandom function, such as hash-based message authentication code (HMAC), to the input password or passphrase along with a salt value and repeats the process many times to produce a derived key, which can then be used as a cryptographic key in subsequent operations. The added computational work makes password cracking much more difficult, and is known as key stretching.
    ///
    /// - parameters:
    ///     - password: Master password from which a derived key is generated
    ///     - salt: A sequence of bits, known as a cryptographic salt
    ///     - rounds: The number of iterations desired. As of 2005 a Kerberos standard recommended 4096 iterations, Apple iOS 3 used 2000, iOS 4 used 10000, while in 2011 LastPass used 5000 iterations for JavaScript clients and 100000 iterations for server-side hashing.
    ///     - derivedKeyLen: The desired length of the derived key
    ///
    /// - [SHA-256 is not a secure password hashing algorithm](https://dusted.codes/sha-256-is-not-a-secure-password-hashing-algorithm)
    /// - [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2)
    public static func PBKDF2(password: Data, salt: Data, rounds: UInt32, derivedKeyLen: Int) throws -> Data {
        var derivedKey = Data(count: derivedKeyLen)
        
        let status = password.withUnsafeBytes { (passwordBytes: UnsafePointer<Int8>) -> Int32 in
            return salt.withUnsafeBytes { (saltBytes: UnsafePointer<UInt8>) -> Int32 in
                return derivedKey.withUnsafeMutableBytes { (derivedKeyBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
                    return CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),                // algorithm
                        passwordBytes, password.count,              // password
                        saltBytes, salt.count,                      // salt,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), // PRF
                        rounds,                                     // rounds
                        derivedKeyBytes, derivedKeyLen              // derived key
                    )
                }
            }
        }
        
        guard status == kCCSuccess else { throw Error.keyDerivationPBKDFFailed(status: status) }
        return derivedKey
    }
    
    public init() {
        blockSize = kCCBlockSizeAES128
        saltSize = 8
    }
    
    public func encrypt(_ data: Data, password: Data) throws -> Info {
        let iv = try type(of: self).createRandomBytes(count: blockSize)
        let salt = try type(of: self).createRandomBytes(count: saltSize)
        let result = try crypt(data: data, password: password, iv: iv, salt: salt, operation: CCOperation(kCCEncrypt))
        return Info(data: result, iv: iv, salt: salt)
    }
    
    public func decrypt(_ info: Info, password: Data) throws -> Data {
        return try crypt(data: info.data, password: password, iv: info.iv, salt: info.salt, operation: CCOperation(kCCDecrypt))
    }
    
    ///  Cryptographically secure random bytes generator
    private static func createRandomBytes(count: Int) throws -> Data {
        var data = Data(count: count)
        let result = data.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, count, $0) }
        guard result == errSecSuccess else { throw Error.randomCopyBytesFailed(status: result) }
        return data
    }
    
    private func crypt(data: Data, password: Data, iv: Data, salt: Data, operation: CCOperation) throws -> Data {
        let rounds: UInt32 = 10000 // ~80ms on an iPhone 4
        
        // get key using salt and password
        let key = try type(of: self).PBKDF2(password: password, salt: salt, rounds: rounds, derivedKeyLen: blockSize)
        
        //See the doc: For block ciphers, the output size will always be less than or
        //equal to the input size plus the size of one block.
        //That's why we need to add the size of one block here
        let cipherDataCount = data.count + blockSize
        var cipherData = Data(count: cipherDataCount)
        
        var outLength: Int = 0
        let status = key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>) in
            return iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>) in
                return data.withUnsafeBytes { (dataBytes: UnsafePointer<UInt8>) in
                    return cipherData.withUnsafeMutableBytes { (cipherBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
                        return CCCrypt(
                            operation,                        // operation
                            CCAlgorithm(kCCAlgorithmAES128),  // algorith
                            CCOptions(kCCOptionPKCS7Padding), // options
                            keyBytes, key.count,           // key
                            ivBytes,                       // iv
                            dataBytes, data.count,         // input
                            cipherBytes, cipherDataCount,  // output
                            &outLength                        // data out moved
                        )
                    }
                }
            }
        }
        
        guard status == kCCSuccess else { throw Error.cryptFailed(status: status) }
        
        cipherData.count = outLength
        return cipherData
    }
    
}
