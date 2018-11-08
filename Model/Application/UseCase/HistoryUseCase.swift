//
//  HistoryUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ヒストリーユースケース
public final class HistoryUseCase {
    public static let s = HistoryUseCase()

    /// ヒストリーバック通知用RX
    public let rx_historyUseCaseDidRequestHistoryBack = PublishSubject<()>()
    /// ヒストリーフォワード通知用RX
    public let rx_historyUseCaseDidRequestHistoryForward = PublishSubject<()>()
    /// ロードリクエスト通知用RX
    public let rx_historyUseCaseDidRequestLoad = PublishSubject<String>()

    private init() {}

    /// ヒストリーバック
    public func goBack() {
        rx_historyUseCaseDidRequestHistoryBack.onNext(())
    }

    /// ヒストリーフォワード
    public func goForward() {
        rx_historyUseCaseDidRequestHistoryForward.onNext(())
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_historyUseCaseDidRequestLoad.onNext(url)
    }

    public func getList() -> [String] {
        return CommonHistoryDataModel.s.getList()
    }

    /// update common history
    public func insert(url: URL?, title: String?) {
        CommonHistoryDataModel.s.insert(url: url, title: title)
        store()
    }

    /// 閲覧、ページ履歴の永続化
    private func store() {
        DispatchQueue(label: ModelConst.APP.QUEUE).async {
            CommonHistoryDataModel.s.store()
        }
    }

    public func select(dateString: String) -> [CommonHistory] {
        return CommonHistoryDataModel.s.select(dateString: dateString)
    }

    /// 検索ワードと検索件数を指定する
    public func select(title: String, readNum: Int) -> [CommonHistory] {
        return CommonHistoryDataModel.s.select(title: title, readNum: readNum)
    }

    public func delete() {
        CommonHistoryDataModel.s.delete()
        store()
    }

    public func delete(historyIds: [String: [String]]) {
        CommonHistoryDataModel.s.delete(historyIds: historyIds)
        store()
    }

    public func expireCheck() {
        CommonHistoryDataModel.s.expireCheck()
    }
}
