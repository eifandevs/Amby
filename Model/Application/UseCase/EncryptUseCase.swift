////
////  EncryptUseCase.swift
////  Qass
////
////  Created by tenma on 2018/08/26.
////  Copyright © 2018年 eifandevs. All rights reserved.
////
//
// import Foundation
// import RxCocoa
// import RxSwift
//
///// 暗号化ユースケース
// public final class EncryptUseCase {
//    public static let s = EncryptUseCase()
//
//    private init() {}
//
//    /// 暗号化
//    public func encrypt(value: String) -> Data {
//        return EncryptService.encrypt(value: value)!
//    }
//
//    /// 複合化
//    public func decrypt(value: Data) -> String {
//        if let value = EncryptService.decrypt(data: value) {
//            return value
//        }
//        return ""
//    }
// }
