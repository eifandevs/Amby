//
//  EncryptHelper.swift
//  Qas
//
//  Created by temma on 2017/09/27.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import CryptoSwift
import Foundation

public class EncryptHelper {
    public static func encrypt(value: String) -> Data {
        let serviceToken = AuthTokenDataModel.s.keychainServiceToken
        let ivToken = AuthTokenDataModel.s.keychainIvToken
        let input = [UInt8](value.utf8)
        do {
            let aes = try AES(key: serviceToken!, iv: ivToken!)
            let encrypted = try aes.encrypt(input)
            return Data(fromArray: encrypted)
        } catch {
            log.error("encrypt error.")
            return Data()
        }
    }

    public static func decrypt(data: Data) -> String {
        let serviceToken = AuthTokenDataModel.s.keychainServiceToken
        let ivToken = AuthTokenDataModel.s.keychainIvToken
        let input = data.toArray(type: UInt8.self)
        do {
            let aes = try AES(key: serviceToken!, iv: ivToken!)
            let decrypted = try aes.decrypt(input)
            return decrypted.reduce("", { $0 + String(format: "%c", $1) })
        } catch {
            log.error("decrypted error.")
            return ""
        }
    }
}
