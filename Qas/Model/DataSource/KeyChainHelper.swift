//
//  KeyChainHelper.swift
//  Qas
//
//  Created by temma on 2017/09/28.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import KeychainAccess

class KeyChainHelper {
    static func saveToken(key: String, value: String) {
        let keychain = Keychain(service: key)
        keychain[key] = value
    }

    static func getToken(key: String) -> String? {
        let keychain = Keychain(service: key)
        return keychain[key]
    }
}
