//
//  PageHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

final class PageHistoryDataModel {
    static let s = PageHistoryDataModel()

    // 現在表示しているwebviewのコンテキスト
    var currentContext: String = UserDefaults.standard.string(forKey: AppConst.KEY_CURRENT_CONTEXT)! {
        didSet {
            log.debug("current context changed. \(oldValue) -> \(currentContext)")
            previousContext = oldValue
            UserDefaults.standard.set(currentContext, forKey: AppConst.KEY_CURRENT_CONTEXT)
        }
    }
    var previousContext: String?

    // webViewそれぞれの履歴とカレントページインデックス
    var histories: [PageHistory] = []
    
    // 現在のページ情報
    var currentHistory: PageHistory {
        return D.find(histories, callback: { $0.context == currentContext })!
    }
    
    // 現在の位置
    var currentLocation: Int {
        return D.findIndex(histories, callback: { $0.context == currentContext })!
    }
    // 通知センター
    private let center = NotificationCenter.default

    private init() {
        // pageHistory読み込み
        do {
            let data = try Data(contentsOf: AppConst.PATH_URL_PAGE_HISTORY)
            histories = NSKeyedUnarchiver.unarchiveObject(with: data) as! [PageHistory]
            log.debug("page history read.")
        } catch let error as NSError {
            let pageHistory = PageHistory()
            histories.append(pageHistory)
            currentContext = pageHistory.context
            UserDefaults.standard.set(currentContext, forKey: AppConst.KEY_CURRENT_CONTEXT)
            log.warning("failed to read page history: \(error)")
        }
    }
    
    /// ロード開始
    func startLoading(context: String) {
        self.center.post(name: .pageHistoryDataModelDidStartLoading, object: context)
    }
    
    func endLoading(context: String) {
        self.center.post(name: .pageHistoryDataModelDidEndLoading, object: context)
    }
    
    /// ページ追加
    func insert(url: String?) {
        let newPage = PageHistory(url: url ?? "")
        histories.append(newPage)
        currentContext = newPage.context
        self.center.post(name: .pageHistoryDataModelDidInsert, object: histories.last!)
    }
    
    /// ページコピー
    func copy() {
        let newPage = PageHistory(url: currentHistory.url)
        histories.append(newPage)
        currentContext = newPage.context
        self.center.post(name: .pageHistoryDataModelDidInsert, object: histories.last!)
    }
    
    /// ページリロード
    func reload() {
        self.center.post(name: .pageHistoryDataModelDidReload, object: nil)
    }
    
    /// 指定ページの削除
    func remove(context: String) {
        // フロントの削除かどうか
        if context == currentContext {
            let deleteLocation = currentLocation
            histories.remove(at: deleteLocation)
            // 削除した結果、ページが存在しない場合は作成する
            if histories.count == 0 {
                self.center.post(name: .pageHistoryDataModelDidRemove, object: ["context": context, "pageExist": false])
                let pageHistory = PageHistory()
                histories.append(pageHistory)
                currentContext = pageHistory.context
                UserDefaults.standard.set(currentContext, forKey: AppConst.KEY_CURRENT_CONTEXT)
                self.center.post(name: .pageHistoryDataModelDidInsert, object: histories.last!)
                return
            } else {
                // 最後の要素を削除した場合は、前のページに戻る
                if deleteLocation == histories.count {
                    currentContext = histories[deleteLocation - 1].context
                } else {
                    currentContext = histories[deleteLocation].context
                }
            }
        }
        self.center.post(name: .pageHistoryDataModelDidRemove, object: ["context": context, "pageExist": true])
    }
    
    /// 表示中ページの変更
    func change(context: String) {
        currentContext = context
        self.center.post(name: .pageHistoryDataModelDidChange, object: currentContext)
    }
    
    /// 前ページに変更
    func goBack() {
        if histories.count > 0 {
            let targetContext = histories[0...histories.count - 1 ~= currentLocation - 1 ? currentLocation - 1 : histories.count - 1].context
            currentContext = targetContext
            self.center.post(name: .pageHistoryDataModelDidChange, object: currentContext)
        }
    }
    
    /// 次ページに変更
    func goNext() {
        if histories.count > 0 {
            let targetContext = histories[0...histories.count - 1 ~= currentLocation + 1 ? currentLocation + 1 : 0].context
            currentContext = targetContext
            self.center.post(name: .pageHistoryDataModelDidChange, object: currentContext)
        }
    }
    
    /// 表示中ページの保存
    func store() {
        if histories.count > 0 {
            let pageHistoryData = NSKeyedArchiver.archivedData(withRootObject: histories)
            do {
                try pageHistoryData.write(to: AppConst.PATH_URL_PAGE_HISTORY)
                log.debug("store each history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
            }
        }
    }
    
    /// 表示中ページ情報の削除
    func delete() {
        Util.deleteFolder(path: AppConst.PATH_PAGE_HISTORY)
    }
}
