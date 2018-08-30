//
//  Logger.swift
//  Model
//
//  Created by tenma on 2018/08/31.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Logger

class ModelLogger {
    class func verbose(fileName _: String = #file, _ message: Any) {
        Logger.verbose(message)
    }

    class func debug(fileName _: String = #file, _ message: Any) {
        Logger.debug(message)
    }

    class func warning(fileName _: String = #file, _ message: Any) {
        Logger.warning(message)
    }

    class func info(fileName _: String = #file, _ message: Any) {
        Logger.info(message)
    }

    class func error(fileName _: String = #file, _ message: Any) {
        Logger.error(message)
    }

    class func eventIn(fileName: String = #file, functionName: String = #function, chain: String = "") {
        let fname = fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        if chain.isEmpty {
            Logger.verbose("\(fname).\(functionName) >>>")
        } else {
            Logger.verbose("\(fname).\(functionName).\(chain) >>>")
        }
    }

    class func eventOut(fileName: String = #file, functionName: String = #function, chain: String = "") {
        let fname = fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        if chain.isEmpty {
            Logger.verbose("\(fname).\(functionName) <<<")
        } else {
            Logger.verbose("\(fname).\(functionName).\(chain) <<<")
        }
    }
}
