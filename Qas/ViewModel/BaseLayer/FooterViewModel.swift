//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class FooterViewModel {
    /// サムネイル追加通知用RX
    let rx_footerViewModelDidAppendThumbnail = PublishSubject<PageHistory>()
    /// サムネイル追加用RX
    let rx_footerViewModelDidInsertThumbnail = PublishSubject<(at: Int, pageHistory: PageHistory)>()
    /// サムネイル変更通知用RX
    let rx_footerViewModelDidChangeThumbnail = PublishSubject<String>()
    /// サムネイル削除用RX
    let rx_footerViewModelDidRemoveThumbnail = PublishSubject<(context: String, pageExist: Bool)>()
    /// ローディング開始通知用RX
    let rx_footerViewModelDidStartLoading = PublishSubject<String>()
    /// ローディング終了通知用RX
    let rx_footerViewModelDidEndLoading = PublishSubject<(context: String, title: String)>()
    
    /// 現在位置
    var pageHistories: [PageHistory] {
        return PageHistoryDataModel.s.histories
    }
    
    var currentHistory: PageHistory {
        return PageHistoryDataModel.s.currentHistory
    }
    
    var currentContext: String {
        return PageHistoryDataModel.s.currentContext
    }
    
    var currentLocation: Int {
        return PageHistoryDataModel.s.currentLocation
    }
        
    /// 通知センター
    let center = NotificationCenter.default
    
    /// Observable自動解放
    let disposeBag = DisposeBag()
    
    init(index: Int) {
        // webview追加
        center.rx.notification(.pageHistoryDataModelDidAppend, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[FooterViewModel Event]: pageHistoryDataModelDidAppend")
                if let notification = notification.element {
                    let pageHistory = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OBJECT] as! PageHistory
                    // 新しいサムネイルを追加
                    self.rx_footerViewModelDidAppendThumbnail.onNext(pageHistory)
                }
            }
            .disposed(by: disposeBag)

        // webview挿入
        center.rx.notification(.pageHistoryDataModelDidInsert, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[FooterViewModel Event]: pageHistoryDataModelDidInsert")
                if let notification = notification.element {
                    let pageHistory = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OBJECT] as! PageHistory
                    let at = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_AT] as! Int
                    // 新しいサムネイルを追加
                    self.rx_footerViewModelDidInsertThumbnail.onNext((at: at, pageHistory: pageHistory))
                }
            }
            .disposed(by: disposeBag)

        // webviewロード開始
        center.rx.notification(.pageHistoryDataModelDidStartLoading, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[FooterViewModel Event]: pageHistoryDataModelDidStartLoading")
                if let notification = notification.element {
                    // FooterViewに通知をする
                    self.rx_footerViewModelDidStartLoading.onNext(notification.object as! String)
                }
            }
            .disposed(by: disposeBag)

        // webviewレンダリング完了
        center.rx.notification(.pageHistoryDataModelDidEndRendering, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[FooterViewModel Event]: pageHistoryDataModelDidEndRendering")
                if let notification = notification.element {
                    // FooterViewに通知をする
                    let context = notification.object as! String
                    if let pageHistory = D.find(PageHistoryDataModel.s.histories, callback: { $0.context == context }) {
                        self.rx_footerViewModelDidEndLoading.onNext((context: context, title: pageHistory.title))
                    }
                }
            }
            .disposed(by: disposeBag)

        // webview切り替え
        center.rx.notification(.pageHistoryDataModelDidChange, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[FooterViewModel Event]: pageHistoryDataModelDidChange")
                if let notification = notification.element {
                    self.rx_footerViewModelDidChangeThumbnail.onNext(notification.object as! String)
                }
            }
            .disposed(by: disposeBag)
        
        // webview削除
        center.rx.notification(.pageHistoryDataModelDidRemove, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[FooterViewModel Event]: pageHistoryDataModelDidRemove")
                if let notification = notification.element {
                    let context = (notification.object as! [String: Any])["context"] as! String
                    let pageExist = (notification.object as! [String: Any])["pageExist"] as! Bool
                    
                    // 実データの削除
                    try! FileManager.default.removeItem(atPath: Util.thumbnailFolderUrl(folder: context).path)
                    self.rx_footerViewModelDidRemoveThumbnail.onNext((context: context, pageExist: pageExist))
                }
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: Public Method
    
    func changePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }
    
    func removePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.remove(context: context)
    }
}
