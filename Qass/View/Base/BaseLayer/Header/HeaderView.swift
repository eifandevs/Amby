//
//  HeaderView.swift
//  Eiger
//
//  Created by tenma on 2017/03/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import CoreLocation
import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class HeaderView: UIView, ShadowView {
    /// 編集開始監視用RX
    let rx_headerViewDidBeginEditing = PublishSubject<()>()
    /// 編集終了監視用RX
    let rx_headerViewDidEndEditing = PublishSubject<()>()

    private let headerField: HeaderField
    private var isEditing = false
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
        return DeviceConst.STATUS_BAR_HEIGHT + ((frame.size.height - DeviceConst.STATUS_BAR_HEIGHT - (AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT)) / 2) - (AppConst.BASE_LAYER_HEADER_PROGRESS_MARGIN)
    }

    private let positionY: (max: CGFloat, min: CGFloat) = (0, -(AppConst.BASE_LAYER_HEADER_HEIGHT - DeviceConst.STATUS_BAR_HEIGHT))

    var fieldAlpha: CGFloat {
        get {
            return headerField.alpha
        }
        set {
            headerField.alpha = newValue
        }
    }

    override init(frame: CGRect) {
        // ヘッダーフィールド
        let headerFieldOriginY = DeviceConst.STATUS_BAR_HEIGHT + ((frame.size.height - DeviceConst.STATUS_BAR_HEIGHT - (AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT)) / 2) - (AppConst.BASE_LAYER_HEADER_PROGRESS_MARGIN)
        headerField = HeaderField(frame: CGRect(x: (DeviceConst.DISPLAY_SIZE.width - AppConst.BASE_LAYER_HEADER_FIELD_WIDTH) / 2, y: headerFieldOriginY, width: AppConst.BASE_LAYER_HEADER_FIELD_WIDTH, height: AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT))

        // ヘッダーアイテム
        let headerFieldItemOriginY = DeviceConst.STATUS_BAR_HEIGHT - (AppConst.BASE_LAYER_HEADER_PROGRESS_MARGIN)
        // ヒストリーバックボタン
        historyBackButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: headerFieldItemOriginY), size: CGSize(width: (frame.size.width - AppConst.BASE_LAYER_HEADER_FIELD_WIDTH) / 4, height: frame.size.height - DeviceConst.STATUS_BAR_HEIGHT)))
        // ヒストリーフォワードボタン
        historyForwardButton = UIButton(frame: CGRect(origin: CGPoint(x: (DeviceConst.DISPLAY_SIZE.width - AppConst.BASE_LAYER_HEADER_FIELD_WIDTH) / 4, y: headerFieldItemOriginY), size: historyBackButton.frame.size))
        // ブックマークボタン
        favoriteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.BASE_LAYER_HEADER_FIELD_WIDTH + (DeviceConst.DISPLAY_SIZE.width - AppConst.BASE_LAYER_HEADER_FIELD_WIDTH) / 2, y: headerFieldItemOriginY), size: historyBackButton.frame.size))
        // 削除ボタン
        deleteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.BASE_LAYER_HEADER_FIELD_WIDTH + (DeviceConst.DISPLAY_SIZE.width - AppConst.BASE_LAYER_HEADER_FIELD_WIDTH) / 4 * 3, y: headerFieldItemOriginY), size: historyBackButton.frame.size))
        // プログレスバー
        progressBar = EGProgressBar(frame: CGRect(x: 0, y: frame.size.height - AppConst.BASE_LAYER_HEADER_PROGRESS_BAR_HEIGHT, width: DeviceConst.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER_HEADER_PROGRESS_BAR_HEIGHT))

        super.init(frame: frame)
        addShadow()
        backgroundColor = UIColor.pastelLightGray

        // ヘッダーアイテム
        let addButton = { (button: UIButton, image: UIImage) -> Void in
            button.setImage(image: image, color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
            button.alpha = 1
            let edgeInset: CGFloat = button.frame.size.width / 7.0769
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset)
            self.addSubview(button)
        }

        // ヒストリバック
        // ボタンタップ
        historyBackButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_historyBackTap")
                guard let `self` = self else { return }
                // サーチメニューが透明になっている時にタップ
                self.viewModel.goBackCommonHistoryDataModel()
                log.eventOut(chain: "rx_historyBackTap")
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(historyBackButton, R.image.circlemenuHistoryback()!)

        // ヒストリフォアード
        // ボタンタップ
        historyForwardButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_historyForwardTap")
                guard let `self` = self else { return }
                self.viewModel.goForwardCommonHistoryDataModel()
                log.eventOut(chain: "rx_historyForwardTap")
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(historyForwardButton, R.image.circlemenuHistoryforward()!)

        // お気に入り登録
        // ボタンタップ
        favoriteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_favoriteTap")
                guard let `self` = self else { return }
                self.viewModel.registerFavoriteDataModel()
                log.eventOut(chain: "rx_favoriteTap")
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(favoriteButton, R.image.headerFavorite()!)

        // 現在のWebView削除
        // ボタンタップ
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_deleteTap")
                guard let `self` = self else { return }
                self.viewModel.removePageHistoryDataModel()
                log.eventOut(chain: "rx_deleteTap")
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(deleteButton, R.image.circlemenuClose()!)

        // ヘッダーフィールド
        headerField.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_headerTap")
                guard let `self` = self else { return }
                self.startEditing()
                log.eventOut(chain: "rx_headerTap")
            })
            .disposed(by: rx.disposeBag)

        // プログレス更新監視
        viewModel.rx_headerViewModelDidChangeProgress
            .subscribe { [weak self] object in
                // ログが大量に表示されるので、コメントアウト
//                log.eventIn(chain: "rx_headerViewModelDidChangeProgress")
                guard let `self` = self else { return }
                if let progress = object.element {
                    self.progressBar.setProgress(progress)
                }
//                log.eventOut(chain: "rx_headerViewModelDidChangeProgress")
            }.disposed(by: rx.disposeBag)

        // テキストフィールド監視
        viewModel.rx_headerViewModelDidChangeField
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_headerViewModelDidChangeField")
                guard let `self` = self else { return }
                if let text = object.element {
                    self.headerField.text = text
                }
                log.eventOut(chain: "rx_headerViewModelDidChangeField")
            }
            .disposed(by: rx.disposeBag)

        // お気に入り監視
        viewModel.rx_headerViewModelDidChangeFavorite
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_headerViewModelDidChangeFavorite")
                guard let `self` = self else { return }
                if let enable = object.element {
                    if enable {
                        // すでに登録済みの場合は、お気に入りボタンの色を変更する
                        self.favoriteButton.setImage(image: R.image.headerFavoriteSelected(), color: UIColor.brilliantBlue)
                    } else {
                        self.favoriteButton.setImage(image: R.image.headerFavorite(), color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
                    }
                }
                log.eventOut(chain: "rx_headerViewModelDidChangeFavorite")
            }
            .disposed(by: rx.disposeBag)

        // 編集開始監視
        viewModel.rx_headerViewModelDidBeginEditing
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_headerViewModelDidBeginEditing")
                guard let `self` = self else { return }
                if let forceEditFlg = object.element {
                    if forceEditFlg {
                        // サークルメニューから検索を押下したとき
                        self.startEditing()
                    } else {
                        // 空のページを表示したとき
                        // 自動で編集状態にする
                        if self.headerField.text.isEmpty {
                            self.startEditing()
                        }
                    }
                }
                log.eventOut(chain: "rx_headerViewModelDidBeginEditing")
            }
            .disposed(by: rx.disposeBag)

        // ヘッダーフィールド編集終了監視
        headerField.rx_headerFieldDidEndEditing
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_headerFieldDidEndEditing")
                guard let `self` = self else { return }
                if let text = object.element {
                    if let text = text, !text.isEmpty {
                        log.debug("suggest word: \(text)")
                        self.rx_headerViewDidEndEditing.onNext(())
                        self.finishEditing(headerFieldUpdate: true)
                        self.viewModel.searchOperationDataModel(text: text)
                    } else {
                        self.rx_headerViewDidEndEditing.onNext(())
                        self.finishEditing(headerFieldUpdate: false)
                    }
                }
                log.eventOut(chain: "rx_headerFieldDidEndEditing")
            }
            .disposed(by: rx.disposeBag)

        // ボタン追加
        addSubview(headerField)

        // プログレスバー追加
        addSubview(progressBar)
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
        frame.origin.y = -(AppConst.BASE_LAYER_HEADER_HEIGHT - DeviceConst.STATUS_BAR_HEIGHT)
        headerItems.forEach { button in
            button.alpha = 0
        }
        headerField.alpha = 0
    }

    func closeKeyBoard() {
        headerField.closeKeyBoard()
    }

    func finishEditing(headerFieldUpdate: Bool) {
        let text = headerField.textField?.text
        headerField.removeInputForm()
        headerField.frame = CGRect(x: (DeviceConst.DISPLAY_SIZE.width - AppConst.BASE_LAYER_HEADER_FIELD_WIDTH) / 2, y: headerFieldOriginY, width: AppConst.BASE_LAYER_HEADER_FIELD_WIDTH, height: AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT)
        headerField.layer.shadowColor = UIColor.black.cgColor
        isEditing = false

        if let text = text, headerFieldUpdate && !text.isEmpty {
            let restoreText = text.isValidUrl ? text : "\(AppConst.PATH_SEARCH)\(text)"
            let encodedText = restoreText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

            headerField.makeContent(restore: true, restoreText: encodedText)
        } else {
            headerField.makeContent(restore: true, restoreText: nil)
        }
    }

    /// ヘッダービューのスライド
    func slide(value: CGFloat) {
        frame.origin.y += value
        headerField.alpha += value / (AppConst.BASE_LAYER_HEADER_HEIGHT - DeviceConst.STATUS_BAR_HEIGHT)
        headerItems.forEach { button in
            button.alpha += value / (AppConst.BASE_LAYER_HEADER_HEIGHT - DeviceConst.STATUS_BAR_HEIGHT)
        }
    }

    /// 検索開始
    private func startEditing() {
        if !isEditing {
            slideToMax()
            isEditing = true
            headerField.removeContent()
            rx_headerViewDidBeginEditing.onNext(())
            UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                self.headerField.frame = self.frame
                self.headerField.layer.shadowColor = UIColor.clear.cgColor
            }, completion: { _ in
                // キーボード表示
                self.headerField.makeInputForm(height: self.headerFieldOriginY)
            })
        }
    }
}
