//
//  WebViewService.swift
//  Amby
//
//  Created by tenma on 2018/11/24.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

class WebViewService {
    func takeForm(webView: EGWebView) -> Form? {
        if let title = webView.title, let host = webView.url?.host, let url = webView.url?.absoluteString {
            let form = Form()
            form.title = title
            form.host = host
            form.url = url

            // take form
            // formの数
            let inputForms = Int(truncating: (webView.evaluateSync(script: "document.forms.length") as? NSNumber) ?? NSNumber(value: 0))

            // 有無判定
            log.debug("inputForms: \(inputForms)")
            if inputForms == 0 { return nil }

            for i in 0 ... inputForms {
                // エレメントの数
                let elementLength = Int(truncating: (webView.evaluateSync(script: "document.forms[\(i)].elements.length") as? NSNumber) ?? NSNumber(value: 0))

                // 有無判定
                log.debug("elementLength: \(elementLength)")
                if elementLength == 0 { continue }

                for j in 0 ... elementLength {
                    // フォームタイプ判定
                    let type = (webView.evaluateSync(script: "document.forms[\(i)].elements[\(j)].type") as? String) ?? ""

                    // 有無判定
                    log.debug("type: \(type)")
                    if type.isEmpty { continue }

                    if (type != "hidden") && (type != "submit") && (type != "checkbox") {
                        let input = Input()
                        let value = (webView.evaluateSync(script: "document.forms[\(i)].elements[\(j)].value") as? String) ?? ""

                        // 有無判定
                        log.debug("value: \(value)")
                        if value.isEmpty { continue }

                        // 値の設定
                        input.type = type
                        input.formIndex = i
                        input.formInputIndex = j
                        input.value = EncryptService.encrypt(value: value)
                        form.inputs.append(input)
                    }
                }
            }

            return form
        }
        return nil
    }
}
