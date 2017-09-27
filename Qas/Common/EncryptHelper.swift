//
//  EncryptHelper.swift
//  Qas
//
//  Created by temma on 2017/09/27.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import CryptoSwift

class EncryptHelper {
    static func encrypt(str: String) -> Data? {
        let input = [UInt8](str.utf8)
        do {
            let aes = try AES(key: AppConst.encryptKey, iv: AppConst.encryptIv)
            let encrypted = try aes.encrypt(input)
            return Data(fromArray: encrypted)
        } catch {
            log.error("encrypt error.")
            return nil
        }
    }
    
    static func decrypt(data: Data) -> String? {
        let input = data.toArray(type: UInt8.self)
        do {
            let aes = try AES(key: AppConst.encryptKey, iv: AppConst.encryptIv)
            let decrypted = try aes.decrypt(input)
            return decrypted.reduce("", { $0 + String(format: "%c", $1)})
        } catch {
            log.error("decrypted error.")
            return nil
        }
    }
}
