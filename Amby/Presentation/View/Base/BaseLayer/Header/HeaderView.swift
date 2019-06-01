//
//  HeaderView.swift
//  Eiger
//
//  Created by tenma on 2017/03/01.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import CommonUtil
import CoreLocation
import Foundation
import RxCocoa
import RxSwift
import UIKit

enum HeaderViewAction {
    case beginSearching
    case endEditing
    case beginGreping
    case endGreping
}

class HeaderView: UIView, ShadowView {
    /// アクション監視用RX
    let rx_action = PublishSubject<HeaderViewAction>()

    private let headerField: HeaderField
    private var isEditing = false
    private var isGreping = false
    private let viewModel = HeaderViewModel()
    private let progressBar: EGProgressBar
    private let historyBackButton: UIButton
    private let historyForwardButton: UIButton
    private let favoriteButton: UIButton
    private let deleteButton: UIButton

    private var headerItems: [UIButton] {
        return [historyBackButton, historyForwardButton, favoriteButton, deleteButton]
    }

    private var headerFieldOriginY: CGFloat {
        return AppConst.DEVICE.STATUS_BAR_HEIGHT + ((frame.size.height - AppConst.DEVICE.STATUS_BAR_HEIGHT - (AppConst.BASE_LAYER.HEADER_FIELD_HEIGHT)) / 2) - (AppConst.BASE_LAYER.HEADER_PROGRESS_MARGIN)
    }

    override init(frame: CGRect) {
        // ヘッダーフィールド
        let headerFieldHeight = (frame.size.height - AppConst.DEVICE.STATUS_BAR_HEIGHT - (AppConst.BASE_LAYER.HEADER_FIELD_HEIGHT)) / 2
        let headerFieldOriginY = AppConst.DEVICE.STATUS_BAR_HEIGHT + headerFieldHeight - (AppConst.BASE_LAYER.HEADER_PROGRESS_MARGIN)
        headerField = HeaderField(frame: CGRect(x: (AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.BASE_LAYER.HEADER_FIELD_WIDTH) / 2, y: headerFieldOriginY, width: AppConst.BASE_LAYER.HEADER_FIELD_WIDTH, height: AppConst.BASE_LAYER.HEADER_FIELD_HEIGHT))

        // ヘッダーアイテム
        let headerFieldItemOriginY = AppConst.DEVICE.STATUS_BAR_HEIGHT - (AppConst.BASE_LAYER.HEADER_PROGRESS_MARGIN)
        // ヒストリーバックボタン
        historyBackButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: headerFieldItemOriginY), size: CGSize(width: (frame.size.width - AppConst.BASE_LAYER.HEADER_FIELD_WIDTH) / 4, height: frame.size.height - AppConst.DEVICE.STATUS_BAR_HEIGHT)))
        // ヒストリーフォワードボタン
        historyForwardButton = UIButton(frame: CGRect(origin: CGPoint(x: (AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.BASE_LAYER.HEADER_FIELD_WIDTH) / 4, y: headerFieldItemOriginY), size: historyBackButton.frame.size))
        // ブックマークボタン
        favoriteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.BASE_LAYER.HEADER_FIELD_WIDTH + (AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.BASE_LAYER.HEADER_FIELD_WIDTH) / 2, y: headerFieldItemOriginY), size: historyBackButton.frame.size))
        // 削除ボタン
        deleteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.BASE_LAYER.HEADER_FIELD_WIDTH + (AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.BASE_LAYER.HEADER_FIELD_WIDTH) / 4 * 3, y: headerFieldItemOriginY), size: historyBackButton.frame.size))
        // プログレスバー
        progressBar = EGProgressBar(frame: CGRect(x: 0, y: frame.size.height - AppConst.BASE_LAYER.HEADER_PROGRESS_BAR_HEIGHT, width: AppConst.DEVICE.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER.HEADER_PROGRESS_BAR_HEIGHT))

        super.init(frame: frame)
        addShadow()
        backgroundColor = UIColor.mediumGray

        setupRx()

        // ボタン追加
        addSubview(headerField)

        // プログレスバー追加
        addSubview(progressBar)
    }

    private func setupRx() {
        // アクション監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                // ログが大量にでるのでコメントアウト
//                log.eventIn(chain: "rx_action")
                guard let `self` = self, let action = action.element else { return }

                switch action {
                case let .updateProgress(progress): self.updateProgress(progress: progress)
                case let .updateFavorite(flag): self.updateFavorite(enable: flag)
                case let .updateField(text): self.updateField(text: text)
                case let .updateCanGoBack(canGoBack): self.updateCanGoBack(canGoBack: canGoBack)
                case let .updateCanGoForward(canGoForward): self.updateCanGoForward(canGoForward: canGoForward)
                case .searchAtMenu: self.searchAtMenu()
                case .searchAtHeader: self.searchAtHeader()
                case .grep: self.grep()
                }
//                log.eventOut(chain: "rx_action")
            }
            .disposed(by: rx.disposeBag)

        // ヘッダーアイテム
        let addButton = { (button: UIButton, image: UIImage) -> Void in
            button.setImage(image: image, color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
            button.alpha = 1
            let edgeInset: CGFloat = button.frame.size.width / 7.0769
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
            self.addSubview(button)
        }

        // ヒストリバック
        // ボタンタップ
        historyBackButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                // サーチメニューが透明になっている時にタップ
                self.viewModel.historyBack()
            })
            .disposed(by: rx.disposeBag)
        historyBackButton.isEnabled = false // default cannot historyback
        // ボタン追加
        addButton(historyBackButton, R.image.circlemenuHistoryback()!)

        // ヒストリフォアード
        // ボタンタップ
        historyForwardButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.historyForward()
            })
            .disposed(by: rx.disposeBag)
        historyForwardButton.isEnabled = false // default cannot historyforward
        // ボタン追加
        addButton(historyForwardButton, R.image.circlemenuHistoryforward()!)

        // お気に入り登録
        // ボタンタップ
        favoriteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.updateFavorite()
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(favoriteButton, R.image.headerFavorite()!)

        // 現在のWebView削除
        // ボタンタップ
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.remove()
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(deleteButton, R.image.circlemenuClose()!)

        // ヘッダーフィールド
        headerField.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.startEditing()
            })
            .disposed(by: rx.disposeBag)

        headerField.rx_action
            .subscribe { [weak self] action in
                log.eventIn(chain: "HeaderField.rx_action")
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .endEditing(text):
                    self.rx_action.onNext(.endEditing)
                    // ヘッダーのクローズボタンタップ or 検索開始
                    if let text = text, !text.isEmpty {
                        log.debug("suggest word: \(text)")
                        self.endEditing(headerFieldUpdate: true)
                        self.viewModel.loadRequest(text: text)
                    } else {
                        self.endEditing(headerFieldUpdate: false)
                    }
                case let .endGreping(text):
                    // ヘッダーのクローズボタンタップ or 検索開始
//                    self.rx_action.onNext(.endGreping)
//                    self.endGreping()

                    if let text = text, !text.isEmpty {
                        log.debug("grep word: \(text)")
                        self.viewModel.grepRequest(word: text)
                    }
                }
                log.eventOut(chain: "HeaderField.rx_action")
            }
            .disposed(by: rx.disposeBag)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }

    /// サイズの最大化。BG->FGにユーザにURLを見せる
    func slideToMax() {
        frame.origin.y = 0
        headerItems.forEach { button in
            button.alpha = 1
        }
        headerField.alpha = 1
    }

    func slideToMin() {
        frame.origin.y = -(AppConst.BASE_LAYER.HEADER_HEIGHT - AppConst.DEVICE.STATUS_BAR_HEIGHT)
        headerItems.forEach { button in
            button.alpha = 0
        }
        headerField.alpha = 0
    }

    func closeKeyBoard() {
        headerField.closeKeyBoard()
    }

    /// 編集終了
    func endEditing(headerFieldUpdate: Bool) {
        let text = headerField.textField?.text
        headerField.removeInputForm()
        headerField.frame = CGRect(x: (AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.BASE_LAYER.HEADER_FIELD_WIDTH) / 2, y: headerFieldOriginY, width: AppConst.BASE_LAYER.HEADER_FIELD_WIDTH, height: AppConst.BASE_LAYER.HEADER_FIELD_HEIGHT)
        headerField.layer.shadowColor = UIColor.black.cgColor
        isEditing = false

        if let text = text, headerFieldUpdate && !text.isEmpty {
            let restoreText = text.isValidUrl ? text : "\(AppConst.URL.SEARCH_PATH)\(text)"

            headerField.makeContent(restore: true, restoreText: restoreText)
        } else {
            headerField.makeContent(restore: true, restoreText: nil)
        }
    }

    /// グレップ終了
    func endGreping() {
        headerField.removeInputForm()
        headerField.frame = CGRect(x: (AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.BASE_LAYER.HEADER_FIELD_WIDTH) / 2, y: headerFieldOriginY, width: AppConst.BASE_LAYER.HEADER_FIELD_WIDTH, height: AppConst.BASE_LAYER.HEADER_FIELD_HEIGHT)
        headerField.layer.shadowColor = UIColor.black.cgColor
        isGreping = false

        headerField.makeContent(restore: true, restoreText: nil)
    }

    /// ヘッダービューのスライド
    func slide(value: CGFloat) {
        frame.origin.y += value
        headerField.alpha += value / (AppConst.BASE_LAYER.HEADER_HEIGHT - AppConst.DEVICE.STATUS_BAR_HEIGHT)
        headerItems.forEach { button in
            button.alpha += value / (AppConst.BASE_LAYER.HEADER_HEIGHT - AppConst.DEVICE.STATUS_BAR_HEIGHT)
        }
    }

    // MARK: - Private Method

    private func updateCanGoBack(canGoBack: Bool) {
        historyBackButton.isEnabled = canGoBack
    }

    private func updateCanGoForward(canGoForward: Bool) {
        historyForwardButton.isEnabled = canGoForward
    }

    private func grep() {
        startGreping()
    }

    private func searchAtMenu() {
        // サークルメニューから検索を押下したとき
        startEditing()
    }

    private func searchAtHeader() {
        // 空のページを表示したとき
        // 自動で編集状態にする
        if headerField.text.isEmpty {
            startEditing()
        }
    }

    private func updateField(text: String) {
        headerField.text = text
    }

    private func updateFavorite(enable: Bool) {
        if enable {
            // すでに登録済みの場合は、お気に入りボタンの色を変更する
            favoriteButton.setImage(image: R.image.headerFavoriteSelected(), color: UIColor.ultraViolet)
        } else {
            favoriteButton.setImage(image: R.image.headerFavorite(), color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        }
    }

    private func updateProgress(progress: CGFloat) {
        progressBar.setProgress(progress)
    }

    /// 検索開始
    private func startEditing() {
        if !isEditing {
            isEditing = true
            headerField.removeContent()
            rx_action.onNext(.beginSearching)
            UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                self.headerField.frame = self.frame
                self.headerField.layer.shadowColor = UIColor.clear.cgColor
            }, completion: { _ in
                // キーボード表示
                self.headerField.startEditing(textFieldY: self.headerFieldOriginY)
            })
        }
    }

    /// グレップ開始
    private func startGreping() {
        if !isGreping {
            isGreping = true
            headerField.removeContent()
            rx_action.onNext(.beginGreping)
            UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                self.headerField.frame = self.frame
                self.headerField.layer.shadowColor = UIColor.clear.cgColor
            }, completion: { _ in
                // キーボード表示
                self.headerField.startGreping(textFieldY: self.headerFieldOriginY)
            })
        }
    }
}
