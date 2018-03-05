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
    let rx_headerViewModelDidChangeFavorite = PublishSubject<Bool>()
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

        // お気に入り登録
        center.rx.notification(.favoriteDataModelDidInsert, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: favoriteDataModelDidInsert")
                let url = PageHistoryDataModel.s.currentHistory.url
                self.rx_headerViewModelDidChangeFavorite.onNext(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
            }
            .disposed(by: disposeBag)
        
        // お気に入り削除
        center.rx.notification(.favoriteDataModelDidRemove, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: favoriteDataModelDidRemove")
                let url = PageHistoryDataModel.s.currentHistory.url
                self.rx_headerViewModelDidChangeFavorite.onNext(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
            }
            .disposed(by: disposeBag)
        
        // お気に入り更新チェック
        center.rx.notification(.favoriteDataModelDidReload, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: favoriteDataModelDidReload")
                let url = PageHistoryDataModel.s.currentHistory.url
                self.rx_headerViewModelDidChangeFavorite.onNext(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
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
        
        // ページ変更
        center.rx.notification(.pageHistoryDataModelDidChange, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: pageHistoryDataModelDidChange")
                let url = PageHistoryDataModel.s.currentHistory.url
                self.rx_headerViewModelDidChangeFavorite.onNext(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
            }
            .disposed(by: disposeBag)

        // ページ追加
        center.rx.notification(.pageHistoryDataModelDidAppend, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: pageHistoryDataModelDidAppend")
                let url = PageHistoryDataModel.s.currentHistory.url
                self.rx_headerViewModelDidChangeFavorite.onNext(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
            }
            .disposed(by: disposeBag)
        
        // ページ挿入
        center.rx.notification(.pageHistoryDataModelDidInsert, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: pageHistoryDataModelDidInsert")
                let url = PageHistoryDataModel.s.currentHistory.url
                self.rx_headerViewModelDidChangeFavorite.onNext(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
            }
            .disposed(by: disposeBag)
        
        // ページ削除
        center.rx.notification(.pageHistoryDataModelDidRemove, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[HeaderViewModel Event]: pageHistoryDataModelDidRemove")
                if let notification = notification.element {
                    let pageExist = (notification.object as! [String: Any])["pageExist"] as! Bool
                    if pageExist {
                        let url = PageHistoryDataModel.s.currentHistory.url
                        self.rx_headerViewModelDidChangeFavorite.onNext(FavoriteDataModel.s.select().map({ $0.url }).contains(url))
                    } else {
                        // ページが存在しない場合は、無条件でお気に入りボタンを無効化
                        self.rx_headerViewModelDidChangeFavorite.onNext(false)
                    }
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
