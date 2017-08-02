//
//  HeaderViewModel.swift
//  Eiger
//
//  Created by temma on 2017/04/30.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol HeaderViewModelDelegate {
    func headerViewModelDidChangeProgress(progress: CGFloat)
    func headerViewModelDidChangeField(text: String)
    func headerViewModelDidChangeFavorite(changed: Bool)
    func headerViewModelDidBeginEditing(forceEditFlg: Bool)
}

class HeaderViewModel {
    // 通知センター
    private let center = NotificationCenter.default
    
    var delegate: HeaderViewModelDelegate?

    init () {
        // プログレスバーの初期化
        center.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] (notification) in
            self!.delegate?.headerViewModelDidChangeProgress(progress: 0)
        }
        // プログレス更新
        center.addObserver(forName: .headerViewModelWillChangeProgress, object: nil, queue: nil) { [weak self] (notification) in
            self!.delegate?.headerViewModelDidChangeProgress(progress: notification.object as! CGFloat)
        }
        // 読み込み終了
        center.addObserver(forName: .headerViewModelWillChangeFavorite, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[HeaderView Event]: headerViewModelWillChangeFavorite")
            self!.delegate?.headerViewModelDidChangeFavorite(changed: notification.object as! Bool)
        }
        // ヘッダーURL更新
        center.addObserver(forName: .headerViewModelWillChangeField, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[HeaderView Event]: headerViewModelWillChangeField")
            self!.delegate?.headerViewModelDidChangeField(text: notification.object as! String)
        }
        // 検索開始
        center.addObserver(forName: .headerViewModelWillBeginEditing, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[HeaderView Event]: headerViewModelWillBeginEditing")
            self!.delegate?.headerViewModelDidBeginEditing(forceEditFlg: notification.object as! Bool)
        }
    }

// MARK: Public Method

    func notifyHistoryBackWebView() {
        center.post(name: .baseViewModelWillHistoryBackWebView, object: nil)
    }

    func notifyHistoryForwardWebView() {
        center.post(name: .baseViewModelWillHistoryForwardWebView, object: nil)
    }
    
    func notifySearchWebView(text: String) {
        center.post(name: .baseViewModelWillSearchWebView, object: text)
    }

    func notifyRegisterAsFavorite() {
        center.post(name: .baseViewModelWillRegisterAsFavorite, object: nil)
    }
    
    func notifyRemoveWebView() {
        center.post(name: .baseViewModelWillRemoveWebView, object: nil)
    }
}
