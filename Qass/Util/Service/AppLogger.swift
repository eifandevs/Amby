//
//  Logger.swift
//  Qass
//
//  Created by tenma on 2018/08/31.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Logger

class AppLogger {
    class func verbose(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Logger.verbose(message, file, function, line: line, context: "P")
    }

    class func debug(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Logger.debug(message, file, function, line: line, context: "P")
    }

    class func warning(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Logger.warning(message, file, function, line: line, context: "P")
    }

    class func info(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Logger.info(message, file, function, line: line, context: "P")
    }

    class func error(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Logger.error(message, file, function, line: line, context: "P")
    }

    class func eventIn(_ file: String = #file, _ function: String = #function, _ line: Int = #line, chain: String = "") {
        let fname = file.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        if chain.isEmpty {
            Logger.verbose("\(fname).\(function) >>>", file, function, line: line, context: "P")
        } else {
            Logger.verbose("\(fname).\(function).\(chain) >>>", file, function, line: line, context: "P")
        }
    }

    class func eventOut(_ file: String = #file, _ function: String = #function, _ line: Int = #line, chain: String = "") {
        let fname = file.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        if chain.isEmpty {
            Logger.verbose("\(fname).\(function) <<<", file, function, line: line, context: "P")
        } else {
            Logger.verbose("\(fname).\(function).\(chain) <<<", file, function, line: line, context: "P")
        }
    }
}
