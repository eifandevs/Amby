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
}
