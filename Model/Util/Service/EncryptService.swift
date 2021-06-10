//
//  EncryptService.swift
//  Amby
//
//  Created by temma on 2017/09/27.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import CommonUtil
import CryptoSwift
import Foundation

public class EncryptService {
    public static func encrypt(value: String) -> String? {
        let serviceToken = AccessTokenDataModel.s.keychainServiceToken
        let ivToken = AccessTokenDataModel.s.keychainIvToken
        let input = [UInt8](value.utf8)
        do {
            let aes = try AES(key: serviceToken!, iv: ivToken!)
            let encrypted = try aes.encrypt(input)
            return String.init(data: Data(fromArray: encrypted), encoding: .utf8)!
        } catch {
            log.error("encrypt error.")
            return nil
        }
    }

    public static func decrypt(dataString: String) -> String {
        let data = dataString.data(using: String.Encoding.utf8)!
        let serviceToken = AccessTokenDataModel.s.keychainServiceToken
        let ivToken = AccessTokenDataModel.s.keychainIvToken
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
