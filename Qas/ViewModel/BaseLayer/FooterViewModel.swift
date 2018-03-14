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
    let rx_footerViewModelDidAppendThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
        .flatMap { pageHistory -> Observable<PageHistory> in
            return Observable.just(pageHistory)
        }
    /// サムネイル追加用RX
    let rx_footerViewModelDidInsertThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
        .flatMap { object -> Observable<(at: Int, pageHistory: PageHistory)> in
            return Observable.just((at: object.at, pageHistory: object.pageHistory))
        }
    /// サムネイル変更通知用RX
    let rx_footerViewModelDidChangeThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
        }
    /// サムネイル削除用RX
    let rx_footerViewModelDidRemoveThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
        .flatMap { object -> Observable<(context: String, pageExist: Bool)> in
            // 実データの削除
            try! FileManager.default.removeItem(atPath: Util.thumbnailFolderUrl(folder: object.context).path)
            return Observable.just((context: object.context, pageExist: object.pageExist))
        }
    /// ローディング開始通知用RX
    let rx_footerViewModelDidStartLoading = PublishSubject<String>()
    /// ローディング終了通知用RX
    let rx_footerViewModelDidEndLoading = PublishSubject<(context: String, title: String)>()
    
    /// 現在位置
    var pageHistories: [PageHistory] {
        return PageHistoryDataModel.s.histories
    }
    
    var currentHistory: PageHistory {
        return PageHistoryDataModel.s.currentHistory!
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
