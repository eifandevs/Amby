//
//  NoticeHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum NoticeHandlerUseCaseAction {
    case present(message: String, isSuccess: Bool)
}

/// 汎用通知ユースケース
public final class NoticeHandlerUseCase {
    public static let s = NoticeHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<NoticeHandlerUseCaseAction>()

    /// models
    private var tabDataModel: TabDataModelProtocol!
    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!
    private var searchHistoryDataModel: SearchHistoryDataModelProtocol!
    private var formDataModel: FormDataModelProtocol!
    private var memoDataModel: MemoDataModelProtocol!
    private var thumbnailDataModel: ThumbnailDataModelProtocol!
    private var issueDataModel: IssueDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        commonHistoryDataModel = CommonHistoryDataModel.s
        favoriteDataModel = FavoriteDataModel.s
        searchHistoryDataModel = SearchHistoryDataModel.s
        formDataModel = FormDataModel.s
        memoDataModel = MemoDataModel.s
        thumbnailDataModel = ThumbnailDataModel.s
        issueDataModel = IssueDataModel.s
    }

    private func setupRx() {
        // 正常終了監視
        Observable
            .merge([
                favoriteDataModel.rx_action.flatMap { action -> Observable<String> in
                    switch action {
                    case .deleteAll: return Observable.just(MessageConst.NOTIFICATION.DELETE_BOOK_MARK)
                    case .insert: return Observable.just(MessageConst.NOTIFICATION.REGISTER_BOOK_MARK)
                    default: return Observable.empty()
                    }
                },
                commonHistoryDataModel.rx_action.flatMap { action -> Observable<String> in
                    if case .deleteAll = action {
                        return Observable.just(MessageConst.NOTIFICATION.DELETE_COMMON_HISTORY)
                    } else {
                        return Observable.empty()
                    }
                },
                formDataModel.rx_action.flatMap { action -> Observable<String> in
                    if case .deleteAll = action {
                        return Observable.just(MessageConst.NOTIFICATION.DELETE_FORM)
                    } else if case .insert = action {
                        return Observable.just(MessageConst.NOTIFICATION.REGISTER_FORM)
                    } else {
                        return Observable.empty()
                    }
                },
                searchHistoryDataModel.rx_action.flatMap { action -> Observable<String> in
                    if case .deleteAll = action {
                        return Observable.just(MessageConst.NOTIFICATION.DELETE_SEARCH_HISTORY)
                    } else {
                        return Observable.empty()
                    }
                },
                issueDataModel.rx_action.flatMap { action -> Observable<String> in
                    if case .registered = action {
                        return Observable.just(MessageConst.NOTIFICATION.REGISTER_REPORT)
                    } else {
                        return Observable.empty()
                    }
                },
                WebCacheHandlerUseCase.s.rx_action.flatMap { action -> Observable<String> in
                    switch action {
                    case .deleteCookies: return Observable.just(MessageConst.NOTIFICATION.DELETE_COOKIES)
                    case .deleteCaches: return Observable.just(MessageConst.NOTIFICATION.DELETE_CACHES)
                    }
                }
            ])
            .subscribe { [weak self] message in
                guard let `self` = self, let message = message.element else { return }
                self.rx_action.onNext(.present(message: message, isSuccess: true))
            }
            .disposed(by: disposeBag)

        // エラー監視
        Observable.merge([
            searchHistoryDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            commonHistoryDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            tabDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            favoriteDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            formDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            memoDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            thumbnailDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            issueDataModel.rx_error.flatMap { Observable.just($0 as ModelError) },
            LocalAuthenticationHandlerUseCase.s.rx_error.flatMap { Observable.just($0 as ModelError) },
            AccessTokenDataModel.s.rx_error.flatMap { Observable.just($0 as ModelError) }
        ]).subscribe { [weak self] modelError in
            guard let `self` = self, let modelError = modelError.element else { return }
            self.rx_action.onNext(.present(message: modelError.message, isSuccess: false))
        }
        .disposed(by: disposeBag)
    }
}
