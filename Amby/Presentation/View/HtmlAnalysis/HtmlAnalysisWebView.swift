//
//  HtmlAnalysisWebView.swift
//  Amby
//
//  Created by tenma on 2019/03/30.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Hydra
import Model
import RxCocoa
import RxSwift
import UIKit
import WebKit

class HtmlAnalysisWebView: WKWebView {
    let resourceUtil = ResourceUtil()

    // promise
    func evaluate(script: String) -> Promise<Any?> {
        return Promise<Any?>(in: .main, token: nil) { resolve, reject, _ in
            self.evaluateJavaScript(script) { result, error in
                if let error = error {
                    log.error("js evaluate error. error: \(error)")
                    reject(error)
                } else {
                    resolve(result)
                }
            }
        }
    }

    func shape(html: String) -> Promise<Any?> {
        return evaluate(script: "shapeWapper('\(html)')")
    }

    func loadShaperHtml() {
        loadFileURL(resourceUtil.shaperURL, allowingReadAccessTo: resourceUtil.shaperURL)
        let request = URLRequest(url: resourceUtil.shaperURL)
        load(request)
    }
}
