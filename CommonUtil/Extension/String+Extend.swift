//
//  String+Extend.swift
//  Eiger
//
//  Created by temma on 2017/02/26.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    /// ランダム文字列作成
    public static func getRandomStringWithLength(length: Int) -> String {
        let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.count)

        return String((0 ..< length).map { _ -> Character in
            alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
        })
    }

    public var isValidUrl: Bool {
        return self != "http://" &&
            self != "https://" &&
            !isEmpty &&
            (hasPrefix("http://") == true || hasPrefix("https://") == true)
    }

    public var isLocalUrl: Bool {
        return hasPrefix("file://")
    }

    public var isUrl: Bool {
        return contains("://")
    }

    public var isHttpsUrl: Bool {
        return hasPrefix("https://")
    }

    public var domainAndPath: String {
        return components(separatedBy: "?").first!
    }

    public var toInt: Int {
        return Int(self)!
    }

    public var tofloat: CGFloat {
        return CGFloat(Double(self)!)
    }

    /// 文字列からDate型作成
    public func toDate(format: String = "yyyyMMdd") -> Date {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: "ja_JP")
        formatter.locale = jaLocale
        formatter.dateFormat = format
        return formatter.date(from: self)!
    }

    public func index(from: Int) -> Index {
        return index(startIndex, offsetBy: from)
    }

    var encodeUrl: String {
        if contains("%") {
            return self
        } else {
            return addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)!
        }
    }

    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }

    var decodeUrl: String {
        return removingPercentEncoding!
    }

    var base64Encode: String {
        let data = self.data(using: .utf8)
        let encodedString = data?.base64EncodedString()
        return encodedString!
    }
}
