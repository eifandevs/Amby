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

/// 通知ユースケース
public final class NoticeUseCase {
    public static let s = NoticeUseCase()

    /// メッセージ通知用RX
    public let rx_noticeUseCaseDidInvoke = PublishSubject<(message: String, isSuccess: Bool)>()

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

        // 閲覧履歴削除失敗監視
        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidDeleteFailure
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_commonHistoryDataModelDidDeleteAllFailure")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_COMMON_HISTORY_ERROR, isSuccess: false))
                log.eventOut(chain: "rx_commonHistoryDataModelDidDeleteAllFailure")
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

        // フォーム削除失敗監視
        FormDataModel.s.rx_formDataModelDidDeleteFailure
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_formDataModelDidDeleteFailure")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_FORM_ERROR, isSuccess: false))
                log.eventOut(chain: "rx_formDataModelDidDeleteFailure")
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

        // お気に入り削除失敗監視
        FavoriteDataModel.s.rx_favoriteDataModelDidDeleteFailure
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_favoriteDataModelDidDeleteFailure")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_BOOK_MARK_ERROR, isSuccess: false))
                log.eventOut(chain: "rx_favoriteDataModelDidDeleteFailure")
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

        // 検索履歴削除失敗監視
        SearchHistoryDataModel.s.rx_searchHistoryDataModelDidDeleteFailure
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_searchHistoryDataModelDidDeleteFailure")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.DELETE_SEARCH_HISTORY_ERROR, isSuccess: false))
                log.eventOut(chain: "rx_searchHistoryDataModelDidDeleteFailure")
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

        // お気に入り情報取得失敗監視
        FavoriteDataModel.s.rx_favoriteDataModelDidGetFailure
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_favoriteDataModelDidGetFailure")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.REGISTER_BOOK_MARK_ERROR, isSuccess: false))
                log.eventOut(chain: "rx_favoriteDataModelDidGetFailure")
            }
            .disposed(by: disposeBag)

        // フォーム登録成功監視
        FormDataModel.s.rx_formDataModelDidInsert
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_formDataModelDidRegisterSuccess")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.REGISTER_FORM, isSuccess: true))
                log.eventOut(chain: "rx_formDataModelDidRegisterSuccess")
            }
            .disposed(by: disposeBag)

        // フォーム情報取得失敗監視
        FormDataModel.s.rx_formDataModelDidGetFailure
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_formDataModelDidGetFailure")
                guard let `self` = self else { return }
                self.rx_noticeUseCaseDidInvoke.onNext((message: MessageConst.NOTIFICATION.REGISTER_FORM_ERROR_INPUT, isSuccess: false))
                log.eventOut(chain: "rx_formDataModelDidGetFailure")
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
