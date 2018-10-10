//
//  MessageConst.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

/// メッセージ定数クラス
struct MessageConst {

    // MARK: - 汎用

    static let COMMON = COMMON_VALUE()
    struct COMMON_VALUE {
        let OK = "OK"
        let ERROR = "エラー"
        let CANCEL = "キャンセル"
    }

    // MARK: - アラート

    static let ALERT = ALERT_VALUE()
    struct ALERT_VALUE {
        let FORM_TITLE = "フォーム自動入力"
        let FORM_SAVE_TITLE = "フォームデータ保存"
        let FORM_EXIST = "保存済みフォームが存在します。自動入力しますか？"
        let FORM_SAVE_MESSAGE = "入力したフォームデータを保存しますか？"
        let DELETE_TITLE = "データ削除"
        let DELETE_COMMON_HISTORY = "閲覧履歴を全て削除します。よろしいですか？"
        let DELETE_BOOK_MARK = "ブックマークを全て削除します。よろしいですか？"
        let DELETE_FORM = "フォームデータを全て削除します。よろしいですか？"
        let DELETE_SEARCH_HISTORY = "検索履歴を全て削除します。よろしいですか？"
        let DELETE_COOKIES = "Cookieデータを全て削除します。よろしいですか？"
        let DELETE_SITE_DATA = "サイトデータを全て削除します。よろしいですか？"
        let DELETE_ALL = "全てのデータを削除し、初期化します。よろしいですか？"
        let OPEN_COMFIRM = "外部アプリで開いてもよろしいですか？"
        let REGISTER_FORM_ERROR_CRAWL = "ページ情報を取得できませんでした"
        let REGISTER_REPORT_ERROR = "不具合・ご意見の登録に失敗しました"
    }

    // MARK: - 通知

    static let NOTIFICATION = NOTIFICATION_VALUE()
    struct NOTIFICATION_VALUE {
        let NEW_TAB = "新規タブイベント"
        let COPY_URL = "URLをコピーしました"
        let REGISTER_BOOK_MARK = "お気に入りに登録しました"
        let REGISTER_FORM = "フォーム情報を登録しました"
        let REGISTER_REPORT = "レポートを登録しました。ご協力ありがとうございました。"
    }

    // MARK: - ヘッダー

    static let HEADER = HEADER_VALUE()
    struct HEADER_VALUE {
        let SEARCH_PLACEHOLDER = "検索ワードまたは、URLを入力"
        let GREP_PLACEHOLDER = "ページ内の検索ワード"
    }

    // MARK: - ヘルプ

    static let HELP = HELP_VALUE()
    struct HELP_VALUE {
        // 履歴
        let HISTORY_SAVE_TITLE = "閲覧履歴、検索履歴の保存日数"
        let HISTORY_SAVE_SUBTITLE = "閲覧履歴、検索履歴の保存日数"
        let HISTORY_SAVE_MESSAGE = "閲覧履歴、検索履歴は過去90日分保存します"
        // サーチ
        let SEARCH_CLOSE_TITLE = "検索ウィンドウの閉じ方"
        let SEARCH_CLOSE_SUBTITLE = "検索ウィンドウの閉じ方"
        let SEARCH_CLOSE_MESSAGE = "検索ウィンドウは、画面端のスワイプで閉じます"
        // フォーム
        let FORM_TITLE = "フォームについて"
        let FORM_SUB_TITLE = "フォームの自動入力"
        let FORM_MESSAGE = "1. Webページ上のフォームを入力する\n\n2. フォーム登録ボタンを押下する\n\n3. 次回からキーボード表示時に、自動入力ダイアログが表示されます"
        // 自動スクロール
        let AUTO_SCROLL_TITLE = "自動スクロールについて"
        let AUTO_SCROLL_SUBTITLE = "スクロール速度の調整"
        let AUTO_SCROLL_MESSAGE = "1. 設定メニューを開く\n\n2. 自動スクロール設定より、変更可能です\n\n3. 自動スクロールは、ページを更新または、再度自動スクロールボタン押下で停止します"
        // タブ移動
        let TAB_TRANSITION_TITLE = "タブ間を移動する"
        let TAB_TRANSITION_SUBTITLE = "タブの移動パターン"
        let TAB_TRANSITION_MESSAGE = "1. Webページ上を左右にスライドする\n\n2. フッターのサムネイルをタップする"
        // タブ削除
        let TAB_DELETE_TITLE = "タブを削除する"
        let TAB_DELETE_SUBTITLE = "タブの削除パターン"
        let TAB_DELETE_MESSAGE = "1. ヘッダー右上の削除ボタン(X)をタップする\n\n2. フッターのサムネイルを長押しする"
        // データ削除
        let DATA_DELETE_TITLE = "保存情報を個別で削除する"
        let DATA_DELETE_SUBTITLE = "保存情報の個別削除"
        let DATA_DELETE_MESSAGE = "1. メインメニューを開き、一覧を表示する\n\n2. セルを長押しする"
    }
}
