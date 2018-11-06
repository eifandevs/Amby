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

    struct COMMON {
        static let OK = "OK"
        static let ERROR = "エラー"
        static let CANCEL = "キャンセル"
    }

    // MARK: - アラート

    struct ALERT {
        static let FORM_TITLE = "フォーム自動入力"
        static let FORM_SAVE_TITLE = "フォームデータ保存"
        static let FORM_EXIST = "保存済みフォームが存在します。自動入力しますか？"
        static let FORM_SAVE_MESSAGE = "入力したフォームデータを保存しますか？"
        static let DELETE_TITLE = "データ削除"
        static let DELETE_COMMON_HISTORY = "閲覧履歴を全て削除します。よろしいですか？"
        static let DELETE_BOOK_MARK = "ブックマークを全て削除します。よろしいですか？"
        static let DELETE_FORM = "フォームデータを全て削除します。よろしいですか？"
        static let DELETE_SEARCH_HISTORY = "検索履歴を全て削除します。よろしいですか？"
        static let DELETE_COOKIES = "Cookieデータを全て削除します。よろしいですか？"
        static let DELETE_SITE_DATA = "サイトデータを全て削除します。よろしいですか？"
        static let DELETE_ALL = "全てのデータを削除し、初期化します。よろしいですか？"
        static let OPEN_COMFIRM = "外部アプリで開いてもよろしいですか？"
        static let PASSCODE_ALREADY_REGISTERED = "パスコードがすでに設定されてます"
        static let PASSCODE_INITIALIZE = "パスコード再設定(アプリの初期化)"
    }

    // MARK: - 通知

    struct NOTIFICATION {
        static let NEW_TAB = "新規タブイベント"
        static let COPY_URL = "URLをコピーしました"
        static let REGISTER_BOOK_MARK = "お気に入りに登録しました"
        static let REGISTER_FORM = "フォーム情報を登録しました"
        static let REGISTER_FORM_ERROR_CRAWL = "ページ情報取得エラー"
        static let REGISTER_REPORT_MULTIPLE_ERROR = "レポート登録エラー。前回投稿時より24時間経過する必要があります"
        static let MENU_ORDER_SUCCESS = "メニューを並び替えました"
        static let MENU_ORDER_CANNOT_SORT = "メニュー並び替えエラー。メニューアイコンは必須です"
        static let MENU_ORDER_ERROR = "メニュー並び替えエラー。12個選択してください"
        static let PASSCODE_REGISTERED = "パスコードを登録しました"
        static let PASSCODE_AUTHENTIFICATED = "パスコート認証されました"
        static let PASSCODE_INPUT_ERROR = "パスコードエラー"
        static let GREP_ERROR = "ページ内検索に失敗しました"
        static let GREP_SUCCESS = { (result: NSNumber) -> String in
            "\(result)件ヒットしました"
        }
    }

    // MARK: - ヘッダー

    struct HEADER {
        static let SEARCH_PLACEHOLDER = "検索ワードまたは、URLを入力"
        static let GREP_PLACEHOLDER = "ページ内の検索ワード"
    }

    // MARK: - オプションメニュー

    struct OPTION_MENU {
        static let MEMO_REFRESH_TEXT = "新規メモの作成"
    }

    // MARK: - お問い合わせ画面

    struct REPORT {
        static let TITLE = "【エスカレーション】Qass不具合・ご意見報告"
    }

    // MARK: - パスコード画面

    struct PASSCODE {
        static let TITLE_INPUT = "パスコードを入力してください"
        static let TITLE_REGISTER = "パスコードを登録します"
        static let TITLE_CONFIRM = "確認のため、もう一度入力してください"
    }

    // MARK: - ヘルプ画面

    struct HELP {
        // 履歴
        static let HISTORY_SAVE_TITLE = "閲覧履歴、検索履歴の保存日数"
        static let HISTORY_SAVE_SUBTITLE = "閲覧履歴、検索履歴の保存日数"
        static let HISTORY_SAVE_MESSAGE = "閲覧履歴、検索履歴は過去90日分保存します"
        // サーチ
        static let SEARCH_CLOSE_TITLE = "検索ウィンドウの閉じ方"
        static let SEARCH_CLOSE_SUBTITLE = "検索ウィンドウの閉じ方"
        static let SEARCH_CLOSE_MESSAGE = "検索ウィンドウは、画面端のスワイプで閉じます"
        // フォーム
        static let FORM_TITLE = "フォームについて"
        static let FORM_SUB_TITLE = "フォームの自動入力"
        static let FORM_MESSAGE = "1. Webページ上のフォームを入力する\n\n2. フォーム登録ボタンを押下する\n\n3. 次回からキーボード表示時に、自動入力ダイアログが表示されます"
        // 自動スクロール
        static let AUTO_SCROLL_TITLE = "自動スクロールについて"
        static let AUTO_SCROLL_SUBTITLE = "スクロール速度の調整"
        static let AUTO_SCROLL_MESSAGE = "1. 設定メニューを開く\n\n2. 自動スクロール設定より、変更可能です\n\n3. 自動スクロールは、ページを更新または、再度自動スクロールボタン押下で停止します"
        // タブ移動
        static let TAB_TRANSITION_TITLE = "タブ間を移動する"
        static let TAB_TRANSITION_SUBTITLE = "タブの移動パターン"
        static let TAB_TRANSITION_MESSAGE = "1. Webページ上を左右にスライドする\n\n2. フッターのサムネイルをタップする"
        // タブ削除
        static let TAB_DELETE_TITLE = "タブを削除する"
        static let TAB_DELETE_SUBTITLE = "タブの削除パターン"
        static let TAB_DELETE_MESSAGE = "1. ヘッダー右上の削除ボタン(X)をタップする\n\n2. フッターのサムネイルを長押しする"
        // データ削除
        static let DATA_DELETE_TITLE = "保存情報を個別で削除する"
        static let DATA_DELETE_SUBTITLE = "保存情報の個別削除"
        static let DATA_DELETE_MESSAGE = "1. メインメニューを開き、一覧を表示する\n\n2. セルを長押しする"
    }
}
