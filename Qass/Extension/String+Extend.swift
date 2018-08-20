//
//  String+Extend.swift
//  Eiger
//
//  Created by temma on 2017/02/26.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /// ランダム文字列作成
    static func getRandomStringWithLength(length: Int) -> String {
        let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.count)

        return String((0 ..< length).map { _ -> Character in
            alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
        })
    }

    var isValidUrl: Bool {
        return self != "http://" &&
            self != "https://" &&
            !isEmpty &&
            (hasPrefix("http://") == true || hasPrefix("https://") == true)
    }

    var isLocalUrl: Bool {
        return hasPrefix("file://")
    }

    var isUrl: Bool {
        return contains("://")
    }

    var isHttpsUrl: Bool {
        return hasPrefix("https://")
    }

    var domainAndPath: String {
        return components(separatedBy: "?").first!
    }

    var toInt: Int {
        return Int(self)!
    }

    var tofloat: CGFloat {
        return CGFloat(Double(self)!)
    }

    /// 文字列からDate型作成
    func toDate(format: String = AppConst.APP.DATE_FORMAT) -> Date {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: AppConst.APP.LOCALE)
        formatter.locale = jaLocale
        formatter.dateFormat = format
        return formatter.date(from: self)!
    }

    func index(from: Int) -> Index {
        return index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex ..< endIndex)
    }
}
