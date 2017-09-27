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
    static func saveToken(token: String) {
        let keychain = Keychain(service: AppConst.keychainServiceToken)
        keychain[AppConst.keychainServiceToken] = token
    }
    
    static func getToken() -> String? {
        let keychain = Keychain(service: AppConst.keychainServiceToken)
        return keychain[AppConst.keychainServiceToken]
    }
}
