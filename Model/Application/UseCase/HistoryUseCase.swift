//
//  HistoryUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum HistoryUseCaseAction {
    case load(url: String)
}

/// ヒストリーユースケース
public final class HistoryUseCase {
    public static let s = HistoryUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<HistoryUseCaseAction>()

    /// models
    private var tabDataModel: TabDataModel!
    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!
    private var settingDataModel: SettingDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        commonHistoryDataModel = CommonHistoryDataModel.s
        settingDataModel = SettingDataModel.s
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_action.onNext(.load(url: url))
    }

    public func getList() -> [String] {
        return commonHistoryDataModel.getList()
    }

    /// update common history
    public func insert(url: URL?, title: String?) {
        // プライベートモードの場合は保存しない
        if tabDataModel.isPrivate {
            log.debug("common history will not insert. ")
        } else {
            commonHistoryDataModel.insert(url: url, title: title)
            store()
        }
    }

    /// 閲覧、ページ履歴の永続化
    private func store() {
        DispatchQueue(label: ModelConst.APP.QUEUE).async {
            self.commonHistoryDataModel.store()
        }
    }

    public func select(dateString: String) -> [CommonHistory] {
        return commonHistoryDataModel.select(dateString: dateString)
    }

    /// 検索ワードと検索件数を指定する
    public func select(title: String, readNum: Int) -> [CommonHistory] {
        return commonHistoryDataModel.select(title: title, readNum: readNum)
    }

    public func delete() {
        commonHistoryDataModel.delete()
        store()
    }

    public func delete(historyIds: [String: [String]]) {
        commonHistoryDataModel.delete(historyIds: historyIds)
        store()
    }

    public func expireCheck() {
        commonHistoryDataModel.expireCheck(historySaveCount: settingDataModel.commonHistorySaveCount)
    }
}
