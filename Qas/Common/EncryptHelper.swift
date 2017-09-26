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
    static func encrypt(str: String) -> [UInt8] {
        let input = [UInt8](str.utf8)
        do {
            let aes = try AES(key: AppConst.encryptKey, iv: AppConst.encryptIv)
            let encrypted = try aes.encrypt(input)
            return encrypted
        } catch {
            log.error("encrypt error.")
            return []
        }
    }
    
    static func decrypt(input: [UInt8]) -> String {
        do {
            let aes = try AES(key: AppConst.encryptKey, iv: AppConst.encryptIv)
            let decrypted = try aes.decrypt(input)
            return decrypted.reduce("", { $0 + String(format: "%c", $1)})
        } catch {
            log.error("decrypted error.")
            return ""
        }
    }
}
