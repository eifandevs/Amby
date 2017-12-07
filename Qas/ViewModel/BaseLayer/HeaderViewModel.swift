//
//  HeaderViewModel.swift
//  Eiger
//
//  Created by temma on 2017/04/30.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol HeaderViewModelDelegate: class {
    func headerViewModelDidChangeProgress(progress: CGFloat)
    func headerViewModelDidChangeField(text: String)
    func headerViewModelDidChangeFavorite(enable: Bool)
    func headerViewModelDidBeginEditing(forceEditFlg: Bool)
}

class HeaderViewModel {
    /// 通知センター
    private let center = NotificationCenter.default
    
    weak var delegate: HeaderViewModelDelegate?

    init () {

        // プログレスバーの初期化
        center.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            self.delegate?.headerViewModelDidChangeProgress(progress: 0)
        }

        // プログレス更新
        center.addObserver(forName: .commonPageDataModelProgressDidUpdate, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            self.delegate?.headerViewModelDidChangeProgress(progress: notification.object as! CGFloat)
        }

        // 読み込み終了
        center.addObserver(forName: .commonPageDataModelFavoriteUrlDidUpdate, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[HeaderView Event]: commonPageDataModelFavoriteUrlDidUpdate")
            let url = notification.object != nil ? (notification.object as! String) : nil
            let enable = { () -> Bool in
                if url == nil {
                    return false
                } else {
                    return FavoriteDataModel.select().map({ $0.url }).contains(url!)
                }
            }()
            self.delegate?.headerViewModelDidChangeFavorite(enable: enable)
        }

        // ヘッダーURL更新
        center.addObserver(forName: .commonPageDataModelHeaderFieldTextDidUpdate, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[HeaderView Event]: commonPageDataModelHeaderFieldTextDidUpdate")
            self.delegate?.headerViewModelDidChangeField(text: notification.object as! String)
        }

        // 検索開始
        center.addObserver(forName: .commonPageDataModelDidBeginEditing, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[HeaderView Event]: commonPageDataModelDidBeginEditing")
            self.delegate?.headerViewModelDidBeginEditing(forceEditFlg: notification.object as! Bool)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
