//
//  Encrypter.swift
//  SwiftJOSE
//
//  Created by Daniel Egger on 13/10/2017.
//  Copyright © 2017 Airside Mobile, Inc. All rights reserved.
//

import Foundation

internal protocol AsymmetricEncrypter {
    init(publicKey: SecKey)
    func encrypt(_ plaintext: Data) -> Data
}

internal protocol SymmetricEncrypter {
    init(symmetricKey: SecKey)
    func encrypt(_ plaintext: Data, with aad: Data) -> EncryptionContext
}

public struct EncryptionContext {
    let ciphertext: Data
    let authenticationTag: Data
    let initializationVector: Data
}

public struct Encrypter {
    let symmetricEncrypter: SymmetricEncrypter
    let encryptedKey: Data
    
    public init(keyEncryptionAlgorithm: Algorithm, keyEncryptionKey kek: SecKey, contentEncyptionAlgorithm: Algorithm, contentEncryptionKey cek: SecKey) {
        // Todo: Find out which available encrypters support the specified algorithms. See https://mohemian.atlassian.net/browse/JOSE-58.
        self.symmetricEncrypter = AESEncrypter(symmetricKey: cek)
        
        // Todo: Convert key to correct representation (check RFC).
        var error: Unmanaged<CFError>?
        let keyData = SecKeyCopyExternalRepresentation(cek, &error)! as Data;
        self.encryptedKey = RSAEncrypter(publicKey: kek).encrypt(keyData)
    }
    
    func encrypt(header: JWEHeader, payload: JWEPayload) -> EncryptionContext {
        return symmetricEncrypter.encrypt(payload.data(), with: header.data().base64URLEncodedData())
    }
}