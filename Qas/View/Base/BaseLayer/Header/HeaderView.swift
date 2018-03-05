//
//  HeaderView.swift
//  Eiger
//
//  Created by tenma on 2017/03/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import NSObject_Rx

class HeaderView: UIView, ShadowView {
    /// 編集開始監視用RX
    let rx_headerViewDidBeginEditing = PublishSubject<Void>()
    /// 編集終了監視用RX
    let rx_headerViewDidEndEditing = PublishSubject<Void>()
    
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
                guard let `self` = self else { return }
                // サーチメニューが透明になっている時にタップ
                self.viewModel.goBackCommonHistoryDataModel()
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(historyBackButton, R.image.circlemenu_historyback()!)
        
        // ヒストリフォアード
        // ボタンタップ
        historyForwardButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.goForwardCommonHistoryDataModel()
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(historyForwardButton, R.image.circlemenu_historyforward()!)
        
        // お気に入り登録
        // ボタンタップ
        favoriteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.registerFavoriteDataModel()
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(favoriteButton, R.image.header_favorite()!)
        
        // 現在のWebView削除
        // ボタンタップ
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.removePageHistoryDataModel()
            })
            .disposed(by: rx.disposeBag)
        // ボタン追加
        addButton(deleteButton, R.image.circlemenu_close()!)

        // ヘッダーフィールド
        headerField.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.startEditing()
            })
            .disposed(by: rx.disposeBag)
        
        // プログレス更新監視
        viewModel.rx_headerViewModelDidChangeProgress
            .subscribe { [weak self] object in
                guard let `self` = self else { return }
                if let progress = object.element {
                    self.progressBar.setProgress(progress)
                }
            }.disposed(by: rx.disposeBag)
        
        // テキストフィールド監視
        viewModel.rx_headerViewModelDidChangeField
            .subscribe { [weak self] object in
                guard let `self` = self else { return }
                if let text = object.element {
                    self.headerField.text = text
                }
            }
            .disposed(by: rx.disposeBag)
        
        // お気に入り監視
        viewModel.rx_headerViewModelDidChangeFavorite
            .subscribe { [weak self] object in
                guard let `self` = self else { return }
                if let enable = object.element {
                    if enable {
                        // すでに登録済みの場合は、お気に入りボタンの色を変更する
                        self.favoriteButton.setImage(image: R.image.header_favorite_selected(), color: UIColor.brilliantBlue)
                    } else {
                        self.favoriteButton.setImage(image: R.image.header_favorite(), color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
                    }
                }
            }
            .disposed(by: rx.disposeBag)
        
        // 編集開始監視
        viewModel.rx_headerViewModelDidBeginEditing
            .subscribe { [weak self] object in
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
            }
            .disposed(by: rx.disposeBag)
        
        // ヘッダーフィールド編集終了監視
        headerField.rx_headerFieldDidEndEditing
            .subscribe { [weak self] object in
                guard let `self` = self else { return }
                if let text = object.element {
                    if let text = text, !text.isEmpty {
                        log.debug("suggest word: \(text)")
                        self.rx_headerViewDidEndEditing.onNext(())
                        self.finishEditing(headerFieldUpdate: true)
                        self.viewModel.notifySearchWebView(text: text)
                    } else {
                        self.rx_headerViewDidEndEditing.onNext(())
                        self.finishEditing(headerFieldUpdate: false)
                    }
                }
            }
            .disposed(by: rx.disposeBag)

        // ボタン追加
        addSubview(headerField)

        // プログレスバー追加
        addSubview(progressBar)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// サイズの最大化。BG->FGにユーザにURLを見せる
    func slideToMax() {
        frame.origin.y = 0
        headerItems.forEach { (button) in
            button.alpha = 1
        }
        headerField.alpha = 1
    }
    
    func slideToMin() {
        frame.origin.y = -(AppConst.BASE_LAYER_HEADER_HEIGHT - DeviceConst.STATUS_BAR_HEIGHT)
        headerItems.forEach { (button) in
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
        self.headerField.layer.shadowColor = UIColor.black.cgColor
        self.isEditing = false
        
        if let text = text, headerFieldUpdate && !text.isEmpty {
            let restoreText = text.hasValidUrl ? text : "\(AppConst.PATH_SEARCH)\(text)"
            let encodedText = restoreText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

            self.headerField.makeContent(restore: true, restoreText: encodedText)
        } else {
            self.headerField.makeContent(restore: true, restoreText: nil)
        }
    }
    
    /// ヘッダービューのスライド
    func slide(value: CGFloat) {
        frame.origin.y += value
        headerField.alpha += value / (AppConst.BASE_LAYER_HEADER_HEIGHT - DeviceConst.STATUS_BAR_HEIGHT)
        headerItems.forEach { (button) in
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
