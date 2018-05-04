//
//  AuthTokenDataModel.swift
//  Qas
//
//  Created by tenma on 2018/04/18.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class AuthTokenDataModel {
    static let s = AuthTokenDataModel()

    /// DBトークン
    let realmEncryptionToken: String!
    /// キーチェーントークン
    let keychainServiceToken: String!
    /// キーチェーンIVトークン
    let keychainIvToken: String!

    private init() {
        let keychainProvider = KeychainProvider()

        if let realmEncryptionToken = keychainProvider.get(key: AppConst.KEY_REALM_TOKEN) {
            self.realmEncryptionToken = realmEncryptionToken
        } else {
            realmEncryptionToken = String.getRandomStringWithLength(length: 64)
            keychainProvider.save(key: AppConst.KEY_REALM_TOKEN, value: realmEncryptionToken)
        }

        if let keychainServiceToken = keychainProvider.get(key: AppConst.KEY_ENCRYPT_SERVICE_TOKEN) {
            self.keychainServiceToken = keychainServiceToken
        } else {
            keychainServiceToken = String.getRandomStringWithLength(length: 32)
            keychainProvider.save(key: AppConst.KEY_ENCRYPT_SERVICE_TOKEN, value: keychainServiceToken)
        }

        if let keychainIvToken = keychainProvider.get(key: AppConst.KEY_ENCRYPT_IV_TOKEN) {
            self.keychainIvToken = keychainIvToken
        } else {
            keychainIvToken = String.getRandomStringWithLength(length: 16)
            keychainProvider.save(key: AppConst.KEY_ENCRYPT_IV_TOKEN, value: keychainIvToken)
    } }
}
