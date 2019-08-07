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
    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!
    private var settingDataModel: SettingDataModelProtocol!

    let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()

        // バックグラウンド時にタブ情報を保存
        NotificationCenter.default.rx.notification(.UIApplicationWillResignActive, object: nil)
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                DispatchQueue(label: ModelConst.APP.QUEUE).async {
                    self.commonHistoryDataModel.store()
                }
            }
            .disposed(by: disposeBag)
    }

    private func setupProtocolImpl() {
        commonHistoryDataModel = CommonHistoryDataModel.s
        settingDataModel = SettingDataModel.s
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_action.onNext(.load(url: url))
    }
}
