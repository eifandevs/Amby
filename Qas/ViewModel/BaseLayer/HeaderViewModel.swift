//
//  HeaderViewModel.swift
//  Eiger
//
//  Created by temma on 2017/04/30.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class HeaderViewModel {
    /// プログレス更新通知用RX
    let rx_headerViewModelDidChangeProgress = PublishSubject<CGFloat>()
    /// テキストフィールド更新通知用RX
    let rx_headerViewModelDidChangeField = PublishSubject<String>()
    /// お気に入り変更通知用RX
    let rx_headerViewModelDidChangeFavorite = Observable
        .merge([
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove.flatMap { _ in Observable.just(()) },
            FavoriteDataModel.s.rx_favoriteDataModelDidInsert.flatMap { _ in Observable.just(()) },
            FavoriteDataModel.s.rx_favoriteDataModelDidRemove.flatMap { _ in Observable.just(()) },
            FavoriteDataModel.s.rx_favoriteDataModelDidReload.flatMap { _ in Observable.just(()) }
        ])
        .flatMap { notification -> Observable<Bool> in
            let url = PageHistoryDataModel.s.currentHistory.url
            if url.isEmpty {
                return Observable.just(false)
            } else {
                return Observable.just(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
            }
        }
    /// 編集開始通知用RX
    let rx_headerViewModelDidBeginEditing = PublishSubject<Bool>()
    
    
    /// 通知センター
    private let center = NotificationCenter.default

    /// Observable自動解放
    let disposeBag = DisposeBag()
    
    init () {

        // プログレスバーの初期化
        center.rx.notification(.UIApplicationDidBecomeActive, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: UIApplicationDidBecomeActive")
                self.rx_headerViewModelDidChangeProgress.onNext(0)
            }
            .disposed(by: disposeBag)
        
        // プログレス更新
        center.rx.notification(.headerViewDataModelProgressDidUpdate, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: headerViewDataModelProgressDidUpdate")
                if let notification = notification.element {
                    self.rx_headerViewModelDidChangeProgress.onNext(notification.object as! CGFloat)
                }
            }
            .disposed(by: disposeBag)
        
        // ヘッダーURL更新
        center.rx.notification(.headerViewDataModelHeaderFieldTextDidUpdate, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: headerViewDataModelHeaderFieldTextDidUpdate")
                if let notification = notification.element {
                    self.rx_headerViewModelDidChangeField.onNext(notification.object as! String)
                }
            }
            .disposed(by: disposeBag)

        // 検索開始
        center.rx.notification(.headerViewDataModelDidBeginEditing, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: headerViewDataModelDidBeginEditing")
                if let notification = notification.element {
                    self.rx_headerViewModelDidBeginEditing.onNext(notification.object as! Bool)
                }
            }
            .disposed(by: disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: Public Method

    func goBackCommonHistoryDataModel() {
        CommonHistoryDataModel.s.goBack()
    }
    
    func goForwardCommonHistoryDataModel() {
        CommonHistoryDataModel.s.goForward()
    }
    
    func notifySearchWebView(text: String) {
        OperationDataModel.s.executeOperation(operation: .search, object: text)
    }

    func registerFavoriteDataModel() {
        FavoriteDataModel.s.register()
    }
    
    func removePageHistoryDataModel() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }
}
