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
        let repository = KeychainRepository()

        if let realmEncryptionToken = repository.get(key: AppConst.KEY.REALM_TOKEN) {
            self.realmEncryptionToken = realmEncryptionToken
        } else {
            realmEncryptionToken = String.getRandomStringWithLength(length: 64)
            repository.save(key: AppConst.KEY.REALM_TOKEN, value: realmEncryptionToken)
        }

        if let keychainServiceToken = repository.get(key: AppConst.KEY.ENCRYPT_SERVICE_TOKEN) {
            self.keychainServiceToken = keychainServiceToken
        } else {
            keychainServiceToken = String.getRandomStringWithLength(length: 32)
            repository.save(key: AppConst.KEY.ENCRYPT_SERVICE_TOKEN, value: keychainServiceToken)
        }

        if let keychainIvToken = repository.get(key: AppConst.KEY.ENCRYPT_IV_TOKEN) {
            self.keychainIvToken = keychainIvToken
        } else {
            keychainIvToken = String.getRandomStringWithLength(length: 16)
            repository.save(key: AppConst.KEY.ENCRYPT_IV_TOKEN, value: keychainIvToken)
        }
    }
}
