//
//  KeychainRepository.swift
//  Amby
//
//  Created by temma on 2017/09/28.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import KeychainAccess

final class KeychainRepository {
    init() {
    }

    func save(key: String, value: String) {
        let keychain = Keychain(service: key)
        keychain[key] = value
    }

    func get(key: String) -> String? {
        let keychain = Keychain(service: key)
        return keychain[key]
    }

    func delete(key: String) {
        let keychain = Keychain(service: key)
        try! keychain.remove(key)
    }
}
