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

protocol HeaderViewDelegate: class {
    func headerViewDidBeginEditing()
    func headerViewDidEndEditing(headerFieldUpdate: Bool)
}

class HeaderView: UIView, HeaderViewModelDelegate, HeaderFieldDelegate, ShadowView {
    weak var delegate: HeaderViewDelegate?
    private let heightMax = AppConst.headerViewHeight
    private var headerField: HeaderField
    private var isEditing = false
    private let viewModel = HeaderViewModel()
    private var progressBar: EGProgressBar
    private var historyBackButton: UIButton
    private var historyForwardButton: UIButton
    private var favoriteButton: UIButton
    private var deleteButton: UIButton

    private var headerItems: [UIButton] {
        get {
            return [historyBackButton, historyForwardButton, favoriteButton, deleteButton]
        }
    }
    
    var fieldAlpha: CGFloat {
        get {
            return headerField.alpha
        }
        set {
            headerField.alpha = newValue
        }
    }
    
    /// ヘッダービューがスライド中かどうかのフラグ
    var isMoving: Bool {
        get {
            return !isLocateMax && !isLocateMin
        }
    }
    
    /// ヘッダービューがMaxポジションにあるかどうかのフラグ
    var isLocateMax: Bool {
        get {
            return frame.origin.y == 0
        }
    }
    
    /// ヘッダービューがMinポジションにあるかどうかのフラグ
    var isLocateMin: Bool {
        get {
            return frame.origin.y == -(AppConst.headerViewHeight - DeviceConst.statusBarHeight)
        }
    }
    
    override init(frame: CGRect) {
        // ヘッダーフィールド
        headerField = HeaderField(frame: CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.66, width: AppConst.headerFieldWidth, height: heightMax * 0.5))
        // ヒストリーバックボタン
        historyBackButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: (frame.size.width - AppConst.headerFieldWidth) / 4, height: frame.size.height)))
        // ヒストリーフォワードボタン
        historyForwardButton = UIButton(frame: CGRect(origin: CGPoint(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4, y: 0), size: historyBackButton.frame.size))
        // ブックマークボタン
        favoriteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.headerFieldWidth + (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: 0), size: historyBackButton.frame.size))
        // 削除ボタン
        deleteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.headerFieldWidth + (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4 * 3, y: 0), size: historyBackButton.frame.size))
        // プログレスバー
        progressBar = EGProgressBar(frame: CGRect(x: 0, y: frame.size.height - 2.1, width: DeviceConst.displaySize.width, height: 2.1))
        
        super.init(frame: frame)
        headerField.delegate = self
        viewModel.delegate = self
        addShadow()
        backgroundColor = UIColor.pastelLightGray
        
        // ヘッダーアイテム
        let addButton = { (button: UIButton, image: UIImage, action: @escaping (() -> ())) -> Void in
            button.setImage(image: image, color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
            button.alpha = 1
            let edgeInset: CGFloat = button.frame.size.width / 7.0769
            button.imageEdgeInsets = UIEdgeInsetsMake(edgeInset + 10.5, edgeInset, edgeInset, edgeInset)
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    guard let `self` = self else { return }
                    action()
            }
            self.addSubview(button)
        }
        
        // ヒストリバック
        addButton(historyBackButton, R.image.circlemenu_historyback()!) { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.notifyHistoryBackWebView()
        }
        
        // ヒストリフォアード
        addButton(historyForwardButton, R.image.circlemenu_historyforward()!) { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.notifyHistoryForwardWebView()
        }
        
        // お気に入り登録
        addButton(favoriteButton, #imageLiteral(resourceName: "header_favorite")) { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.notifyRegisterAsFavorite()
        }
        // 現在のWebView削除
        addButton(deleteButton, R.image.circlemenu_close()!, { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.notifyRemoveWebView()
        })
        
        _ = headerField.reactive.controlEvents(.touchUpInside)
            .observeNext { [weak self] _ in
                guard let `self` = self else { return }
                self.startEditing()
        }
        
        addSubview(headerField)
        addSubview(progressBar)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        frame.origin.y = -(AppConst.headerViewHeight - DeviceConst.statusBarHeight)
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
        
        headerField.frame = CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.66, width: AppConst.headerFieldWidth, height: heightMax * 0.5)
        self.headerField.layer.shadowColor = UIColor.black.cgColor
        self.isEditing = false
        
        if let text = text, headerFieldUpdate && !text.isEmpty {
            let restoreText = text.hasValidUrl ? text : "\(AppConst.searchPath)\(text)"
            let encodedText = restoreText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

            self.headerField.makeContent(restore: true, restoreText: encodedText)
        } else {
            self.headerField.makeContent(restore: true, restoreText: nil)
        }
    }
    
    func slide(value: CGFloat) {
        frame.origin.y += value
        headerField.alpha += value / (heightMax - DeviceConst.statusBarHeight)
        headerItems.forEach { (button) in
            button.alpha += value / (heightMax - DeviceConst.statusBarHeight)
        }
    }
    
// MARK: EGTextField Delegate
    func headerFieldDidEndEditing(text: String?) {
        if let text = text, !text.isEmpty {
            self.delegate?.headerViewDidEndEditing(headerFieldUpdate: true)
            viewModel.notifySearchWebView(text: text)
        } else {
            self.delegate?.headerViewDidEndEditing(headerFieldUpdate: false)
        }
    }

// MARK: HeaderViewModel Delegate
    
    func headerViewModelDidChangeProgress(progress: CGFloat) {
        progressBar.setProgress(progress)
    }
    
    func headerViewModelDidChangeField(text: String) {
        headerField.text = text
    }
    
    func headerViewModelDidChangeFavorite(changed: Bool) {
        if changed {
            // すでに登録済みの場合は、お気に入りボタンの色を変更する
            favoriteButton.setImage(image: R.image.header_favorite_selected(), color: UIColor.lightBlue)
        } else {
            favoriteButton.setImage(image: R.image.header_favorite(), color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        }
    }
    
    func headerViewModelDidBeginEditing(forceEditFlg: Bool) {
        if forceEditFlg {
            // サークルメニューから検索を押下したとき
            startEditing()
        } else {
            // 空のページを表示したとき
            // 自動で編集状態にする
            if headerField.text.isEmpty {
                startEditing()
            }
        }
    }
    
    /// 検索開始
    func startEditing() {
        if !isEditing {
            slideToMax()
            isEditing = true
            headerField.removeContent()
            delegate?.headerViewDidBeginEditing()
            UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                self.headerField.frame = self.frame
                self.headerField.layer.shadowColor = UIColor.clear.cgColor
            }, completion: { _ in
                // キーボード表示
                self.headerField.makeInputForm(height: self.frame.size.height - self.heightMax * 0.66)
            })
        }
    }
}
