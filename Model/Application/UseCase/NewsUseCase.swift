//
//  NewsUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum NewsUseCaseAction {
    case update(articles: [Article])
}

/// ニュースユースケース
public final class NewsUseCase {
    public static let s = NewsUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<NewsUseCaseAction>()

    /// models
    private var articleDataModel: ArticleDataModelProtocol!

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    private func setupProtocolImpl() {
        articleDataModel = ArticleDataModel.s
    }

    private func setupRx() {
        articleDataModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self else { return }
                if let action = action.element, case let .update(articles) = action {
                    self.rx_action.onNext(.update(articles: articles))
                }
            }
            .disposed(by: disposeBag)
    }

    public func get() {
        articleDataModel.get()
    }
}
