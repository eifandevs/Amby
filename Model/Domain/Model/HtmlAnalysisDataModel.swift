//
//  HtmlAnalysisDataModel.swift
//  Model
//
//  Created by tenma on 2019/03/29.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol HtmlAnalysisDataModelProtocol {
    func insertHtml(url: String, value: String)
    func getHtml(url: String) -> String?
}

final class HtmlAnalysisDataModel: HtmlAnalysisDataModelProtocol {
    static let s = HtmlAnalysisDataModel()

    var htmlDic: [String: String] = [:]

    private init() {}

    func insertHtml(url: String, value: String) {
        htmlDic[url] = value
    }

    func getHtml(url: String) -> String? {
        return htmlDic[url]
    }
}
