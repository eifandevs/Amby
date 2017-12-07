//
//  CommonPageDataModel.swift
//  Qas
//
//  Created by jmas on 2017/12/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

/// ページ共通データモデル
final class CommonPageDataModel {
    static let s = CommonPageDataModel()
    let center = NotificationCenter.default
    
    // プログレス
    private var progress = 0.f
    
    // ヘッダーテキスト
    private var headerFieldText = ""
    
    // お気に入り登録URL
    private var favoriteUrl: String?
    
    /// プログレス情報の更新
    func updateProgress(progress: CGFloat) {
        self.progress = progress
        center.post(name: .commonPageDataModelProgressDidUpdate, object: progress)
    }
    
    /// ヘッダーテキストの更新
    func updateHeaderFieldText(text: String) {
        headerFieldText = text
        center.post(name: .commonPageDataModelHeaderFieldTextDidUpdate, object: text)
    }
    
    /// お気に入り登録URLの更新
    func updateFavoriteUrl(url: String?) {
        self.favoriteUrl = url
        center.post(name: .commonPageDataModelFavoriteUrlDidUpdate, object: url)
    }
    
    /// 編集開始通知
    func beginEditing(forceEditFlg: Bool) {
        center.post(name: .commonPageDataModelDidBeginEditing, object: forceEditFlg)
    }
}
