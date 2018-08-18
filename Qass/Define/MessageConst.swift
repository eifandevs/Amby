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

    // MARK: - 汎用

    static let COMMON_OK = "OK"
    static let COMMON_CANCEL = "キャンセル"

    // MARK: - アラート

    static let ALERT_FORM_TITLE = "フォーム自動入力"
    static let ALERT_FORM_SAVE_TITLE = "フォームデータ保存"
    static let ALERT_FORM_EXIST = "保存済みフォームが存在します。自動入力しますか？"
    static let ALERT_FORM_SAVE_MESSAGE = "入力したフォームデータを保存しますか？"
    static let ALERT_DELETE_TITLE = "データ削除"
    static let ALERT_DELETE_COMMON_HISTORY = "閲覧履歴を全て削除します。よろしいですか？"
    static let ALERT_DELETE_BOOK_MARK = "ブックマークを全て削除します。よろしいですか？"
    static let ALERT_DELETE_FORM = "フォームデータを全て削除します。よろしいですか？"
    static let ALERT_DELETE_SEARCH_HISTORY = "検索履歴を全て削除します。よろしいですか？"
    static let ALERT_DELETE_COOKIES = "Cookieデータを全て削除します。よろしいですか？"
    static let ALERT_DELETE_SITE_DATA = "サイトデータを全て削除します。よろしいですか？"
    static let ALERT_DELETE_ALL = "全てのデータを削除し、初期化します。よろしいですか？"
    static let ALERT_OPEN_COMFIRM = "外部アプリで開いてもよろしいですか？"

    // MARK: - 通知

    static let NOTIFICATION_COPY_URL = "URLをコピーしました"
    static let NOTIFICATION_REGISTER_BOOK_MARK = "お気に入りに登録しました"
    static let NOTIFICATION_REGISTER_BOOK_MARK_ERROR = "ページ情報を取得できませんでした"
    static let NOTIFICATION_REGISTER_FORM = "フォーム情報を登録しました"
    static let NOTIFICATION_REGISTER_FORM_ERROR_INPUT = "フォーム情報の入力を確認できませんでした"
    static let NOTIFICATION_REGISTER_FORM_ERROR_CRAWL = "ページ情報を取得できませんでした"

    // MARK: - ヘッダー

    static let HEADER_SEARCH_PLACEHOLDER = "検索ワードまたは、URLを入力"
    static let HEADER_GREP_PLACEHOLDER = "ページ内の検索ワード"

    // MARK: - ヘルプ

    // 履歴
    static let HELP_HISTORY_SAVE_TITLE = "閲覧履歴、検索履歴の保存日数"
    static let HELP_HISTORY_SAVE_SUBTITLE = "閲覧履歴、検索履歴の保存日数"
    static let HELP_HISTORY_SAVE_MESSAGE = "閲覧履歴、検索履歴は過去90日分保存します"
    // サーチ
    static let HELP_SEARCH_CLOSE_TITLE = "検索ウィンドウの閉じ方"
    static let HELP_SEARCH_CLOSE_SUBTITLE = "検索ウィンドウの閉じ方"
    static let HELP_SEARCH_CLOSE_MESSAGE = "検索ウィンドウは、画面端のスワイプで閉じます"
    // フォーム
    static let HELP_FORM_TITLE = "フォームについて"
    static let HELP_FORM_SUB_TITLE = "フォームの自動入力"
    static let HELP_FORM_MESSAGE = "1. Webページ上のフォームを入力する\n\n2. フォーム登録ボタンを押下する\n\n3. 次回からキーボード表示時に、自動入力ダイアログが表示されます"
    // 自動スクロール
    static let HELP_AUTO_SCROLL_TITLE = "自動スクロールについて"
    static let HELP_AUTO_SCROLL_SUBTITLE = "スクロール速度の調整"
    static let HELP_AUTO_SCROLL_MESSAGE = "1. 設定メニューを開く\n\n2. 自動スクロール設定より、変更可能です\n\n3. 自動スクロールは、ページを更新または、再度自動スクロールボタン押下で停止します"
    // タブ移動
    static let HELP_TAB_TRANSITION_TITLE = "タブ間を移動する"
    static let HELP_TAB_TRANSITION_SUBTITLE = "タブの移動パターン"
    static let HELP_TAB_TRANSITION_MESSAGE = "1. Webページ上を左右にスライドする\n\n2. フッターのサムネイルをタップする"
    // タブ削除
    static let HELP_TAB_DELETE_TITLE = "タブを削除する"
    static let HELP_TAB_DELETE_SUBTITLE = "タブの削除パターン"
    static let HELP_TAB_DELETE_MESSAGE = "1. ヘッダー右上の削除ボタン(X)をタップする\n\n2. フッターのサムネイルを長押しする"
    // データ削除
    static let HELP_DATA_DELETE_TITLE = "保存情報を個別で削除する"
    static let HELP_DATA_DELETE_SUBTITLE = "保存情報の個別削除"
    static let HELP_DATA_DELETE_MESSAGE = "1. メインメニューを開き、一覧を表示する\n\n2. セルを長押しする"
}
