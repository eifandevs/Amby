//
//  MessageConst.swift
//  Model
//
//  Created by tenma on 2018/09/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

struct MessageConst {

    // MARK: - 通知

    struct NOTIFICATION {
        static let COMMON_ERROR = "通信に失敗しました"
        static let REGISTER_BOOK_MARK = "お気に入りに登録しました"
        static let DELETE_SEARCH_HISTORY = "検索履歴を削除しました"
        static let DELETE_TAB_ERROR = "タブ情報の削除に失敗しました"
        static let FETCH_TAB_ERROR = "タブ情報の取得に失敗しました"
        static let STORE_TAB_ERROR = "タブ情報の保存に失敗しました"
        static let POST_ISSUE_ERROR = "送信に失敗しました"
        static let DELETE_THUMBNAIL_ERROR = "サムネイルの削除に失敗しました"
        static let STORE_THUMBNAIL_ERROR = "サムネイルの保存に失敗しました"
        static let CREATE_THUMBNAIL_ERROR = "サムネイルフォルダの作成に失敗しました"
        static let GET_MEMO_ERROR = "メモ情報の取得に失敗しました"
        static let POST_MEMO_ERROR = "メモ情報の同期に失敗しました"
        static let UPDATE_MEMO_ERROR = "メモ情報の更新に失敗しました"
        static let STORE_MEMO_ERROR = "メモ情報の保存に失敗しました"
        static let DELETE_MEMO_ERROR = "メモ情報の削除に失敗しました"
        static let GET_SEARCH_HISTORY_ERROR = "検索履歴の取得に失敗しました"
        static let GET_SUGGEST_ERROR = "サジェストの取得に失敗しました"
        static let STORE_SEARCH_HISTORY_ERROR = "検索履歴の保存に失敗しました"
        static let DELETE_SEARCH_HISTORY_ERROR = "検索履歴の削除に失敗しました"
        static let DELETE_BOOK_MARK = "お気に入りを削除しました"
        static let LOGIN = "ログインしました"
        static let LOGIN_ERROR = "ログインエラー"
        static let DELETE_BOOK_MARK_ERROR = "お気に入りの削除に失敗しました"
        static let DELETE_COMMON_HISTORY = "閲覧履歴を削除しました"
        static let GET_COMMON_HISTORY_ERROR = "閲覧履歴の取得に失敗しました"
        static let GET_ARTICLE_ERROR = "記事の取得に失敗しました"
        static let GET_FAVORITE_ERROR = "お気に入りの取得に失敗しました"
        static let POST_FAVORITE_ERROR = "お気に入りの同期に失敗しました"
        static let STORE_FAVORITE_ERROR = "お気に入りの保存に失敗しました"
        static let DELETE_FAVORITE_ERROR = "お気に入りの削除に失敗しました"
        static let STORE_COMMON_HISTORY_ERROR = "閲覧履歴の保存に失敗しました"
        static let DELETE_COMMON_HISTORY_ERROR = "閲覧履歴の削除に失敗しました"
        static let DELETE_COOKIES = "クッキー情報を削除しました"
        static let DELETE_CACHES = "キャッシュ情報を削除しました"
        static let DELETE_FORM = "フォーム情報を削除しました"
        static let DELETE_FORM_ERROR = "フォーム情報の削除に失敗しました"
        static let POST_FORM_ERROR = "フォーム情報の同期に失敗しました"
        static let GET_FORM_ERROR = "フォーム情報の取得に失敗しました"
        static let STORE_FORM_ERROR = "フォーム情報の保存に失敗しました"
        static let CANNOT_USE_BIOMETRICS_AUTH = "デバイス認証を利用できません"
        static let INPUT_ERROR_AUTH = "認証に失敗しました"
        static let HTML_ANALYSIS_NOT_EXIST_URL = "URLの取得に失敗しました"
        static let REGISTER_BOOK_MARK_ERROR = "ページ情報を取得できませんでした"
        static let REGISTER_FORM = "フォーム情報を登録しました"
        static let REGISTER_FORM_ERROR_INPUT = "フォーム情報の入力を確認できませんでした"
        static let REGISTER_FORM_ERROR_CRAWL = "ページ情報を取得できませんでした"
        static let REGISTER_REPORT = "レポートを登録しました。ご協力ありがとうございました"
        static let REGISTER_REPORT_ERROR = "レポートの登録に失敗しました"
    }
}
