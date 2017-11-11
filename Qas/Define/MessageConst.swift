//
//  MessageConst.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

/// メッセージ定数クラス
final class MessageConst {
    
    // MARK: - アラート
    static let ALERT_FORM_TITLE = "フォーム自動入力"
    static let ALERT_FORM_EXIST = "保存済みフォームが存在します。自動入力しますか？"
    static let ALERT_DELETE_TITLE = "データ削除"
    static let ALERT_DELETE_COMMON_HISTORY = "閲覧履歴を全て削除します。よろしいですか？"
    static let ALERT_DELETE_BOOK_MARK = "ブックマークを全て削除します。よろしいですか？"
    static let ALERT_DELETE_FORM = "フォームデータを全て削除します。よろしいですか？"
    static let ALERT_DELETE_SEARCH_HISTORY = "検索履歴を全て削除します。よろしいですか？"
    static let ALERT_DELETE_COOKIES = "Cookieデータを全て削除します。よろしいですか？"
    static let ALERT_DELETE_SITE_DATA = "サイトデータを全て削除します。よろしいですか？"
    static let ALERT_DELETE_ALL = "全てのデータを削除し、初期化します。よろしいですか？"
    
    // MARK: - 通知
    static let NOTIFICATION_COPY_URL = "URLをコピーしました"
    static let NOTIFICATION_REGISTER_BOOK_MARK = "お気に入りに登録しました"
    static let NOTIFICATION_REGISTER_BOOK_MARK_ERROR = "ページ情報を取得できませんでした"
    static let NOTIFICATION_REGISTER_FORM = "フォーム情報を登録しました"
    static let NOTIFICATION_REGISTER_FORM_ERROR_INPUT = "フォーム情報の入力を確認できませんでした"
    static let NOTIFICATION_REGISTER_FORM_ERROR_CRAWL = "ページ情報を取得できませんでした"
}
