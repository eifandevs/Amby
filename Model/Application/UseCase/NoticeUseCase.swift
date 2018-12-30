//
//  NoticeUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum NoticeUseCaseAction {
    case notice(message: String, isSuccess: Bool)
}

/// 汎用通知ユースケース
public final class NoticeUseCase {
    public static let s = NoticeUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<NoticeUseCaseAction>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        // 閲覧履歴削除監視
        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidDeleteAll
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_commonHistoryDataModelDidDeleteAll")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_COMMON_HISTORY, isSuccess: true))
                log.eventOut(chain: "rx_commonHistoryDataModelDidDeleteAll")
            }
            .disposed(by: disposeBag)

        // フォーム削除監視
        FormDataModel.s.rx_formDataModelDidDeleteAll
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_formDataModelDidDeleteAll")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_FORM, isSuccess: true))
                log.eventOut(chain: "rx_formDataModelDidDeleteAll")
            }
            .disposed(by: disposeBag)

        // お気に入り削除監視
        FavoriteDataModel.s.rx_favoriteDataModelDidDeleteAll
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_favoriteDataModelDidDeleteAll")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_BOOK_MARK, isSuccess: true))
                log.eventOut(chain: "rx_favoriteDataModelDidDeleteAll")
            }
            .disposed(by: disposeBag)

        // 検索履歴削除監視
        SearchHistoryDataModel.s.rx_searchHistoryDataModelDidDeleteAll
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_searchHistoryDataModelDidDeleteAll")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_SEARCH_HISTORY, isSuccess: true))
                log.eventOut(chain: "rx_searchHistoryDataModelDidDeleteAll")
            }
            .disposed(by: disposeBag)

        // 正常終了監視
        
        // エラー監視
        Observable.merge([
            SearchHistoryDataModel.s.rx_error.flatMap { Observable.just($0 as ModelError) },
            CommonHistoryDataModel.s.rx_error.flatMap { Observable.just($0 as ModelError) },
            PageHistoryDataModel.s.rx_error.flatMap { Observable.just($0 as ModelError) },
            FavoriteDataModel.s.rx_error.flatMap { Observable.just($0 as ModelError) },
            FormDataModel.s.rx_error.flatMap { Observable.just($0 as ModelError) },
            MemoDataModel.s.rx_error.flatMap { Observable.just($0 as ModelError) },
            ThumbnailDataModel.s.rx_error.flatMap({ Observable.just($0 as ModelError) }),
            IssueDataModel.s.rx_error.flatMap({ Observable.just($0 as ModelError) }),
            PasscodeUseCase.s.rx_error.flatMap({ Observable.just($0 as ModelError) })
        ]).subscribe { [weak self] modelError in
            guard let `self` = self, let modelError = modelError.element else { return }
            self.rx_action.onNext(.notice(message: modelError.message, isSuccess: false))
        }
        .disposed(by: disposeBag)

        // お気に入り登録監視
        FavoriteDataModel.s.rx_favoriteDataModelDidInsert
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_favoriteDataModelDidRegisterSuccess")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.REGISTER_BOOK_MARK, isSuccess: true))
                log.eventOut(chain: "rx_favoriteDataModelDidRegisterSuccess")
            }
            .disposed(by: disposeBag)

        // レポート登録成功監視
        IssueDataModel.s.rx_issueDataModelDidRegisterSuccess
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_issueDataModelDidRegisterSuccess")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.REGISTER_REPORT, isSuccess: true))
                log.eventOut(chain: "rx_issueDataModelDidRegisterSuccess")
            }
            .disposed(by: disposeBag)


        // クッキー削除成功監視
        CacheUseCase.s.rx_cacheUseCaseDidDeleteCookies
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_cacheUseCaseDidDeleteCookies")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_COOKIES, isSuccess: true))
                log.eventOut(chain: "rx_cacheUseCaseDidDeleteCookies")
            }
            .disposed(by: disposeBag)

        // キャッシュ削除成功監視
        CacheUseCase.s.rx_cacheUseCaseDidDeleteCaches
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_cacheUseCaseDidDeleteCaches")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_CACHES, isSuccess: true))
                log.eventOut(chain: "rx_cacheUseCaseDidDeleteCaches")
            }
            .disposed(by: disposeBag)
    }
}
