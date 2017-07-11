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
    var hasValidUrl: Bool {
        get {
            return self != "http://" &&
                   self != "https://" &&
                   !isEmpty &&
                   (hasPrefix("http://") == true || hasPrefix("https://") == true)
        }
    }    
    var hasLocalUrl: Bool {
        get {
            return hasPrefix("file://")
        }
    }
    
    var hasHttpsUrl: Bool {
        get {
            return hasPrefix("https://")
        }
    }
    
    var domainAndPath: String {
        get {
            return self.components(separatedBy: "?").first!
        }
    }
    
    var toInt: Int {
        get {
            return Int(self)!
        }
    }
    
    var tofloat: CGFloat {
        get {
            return CGFloat(Double(self)!)
        }
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
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
        return substring(with: startIndex..<endIndex)
    }
}

