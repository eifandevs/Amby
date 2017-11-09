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
        return DeviceConst.statusBarHeight + ((frame.size.height - DeviceConst.statusBarHeight - (AppConst.headerViewHeight * 0.5)) / 2)
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
        let headerFieldOriginY = DeviceConst.statusBarHeight + ((frame.size.height - DeviceConst.statusBarHeight - (AppConst.headerViewHeight * 0.5)) / 2)
        // ヘッダーフィールド
        headerField = HeaderField(frame: CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: headerFieldOriginY, width: AppConst.headerFieldWidth, height: AppConst.headerViewHeight * 0.5))
        // ヒストリーバックボタン
        historyBackButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: DeviceConst.statusBarHeight), size: CGSize(width: (frame.size.width - AppConst.headerFieldWidth) / 4, height: frame.size.height - DeviceConst.statusBarHeight)))
        // ヒストリーフォワードボタン
        historyForwardButton = UIButton(frame: CGRect(origin: CGPoint(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4, y: DeviceConst.statusBarHeight), size: historyBackButton.frame.size))
        // ブックマークボタン
        favoriteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.headerFieldWidth + (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: DeviceConst.statusBarHeight), size: historyBackButton.frame.size))
        // 削除ボタン
        deleteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.headerFieldWidth + (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4 * 3, y: DeviceConst.statusBarHeight), size: historyBackButton.frame.size))
        // プログレスバー
        progressBar = EGProgressBar(frame: CGRect(x: 0, y: frame.size.height - 2.1, width: DeviceConst.displaySize.width, height: 2.1))
        
        super.init(frame: frame)
        headerField.delegate = self
        viewModel.delegate = self
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
        historyBackButton.addTarget(self, action: #selector(self.onTappedHistoryBackButton(_:)), for: .touchUpInside)
        addButton(historyBackButton, R.image.circlemenu_historyback()!)
        
        // ヒストリフォアード
        historyForwardButton.addTarget(self, action: #selector(self.onTappedHistoryForwardButton(_:)), for: .touchUpInside)
        addButton(historyForwardButton, R.image.circlemenu_historyforward()!)
        
        // お気に入り登録
        favoriteButton.addTarget(self, action: #selector(self.onTappedFavoriteButton(_:)), for: .touchUpInside)
        addButton(favoriteButton, R.image.header_favorite()!)
        
        // 現在のWebView削除
        deleteButton.addTarget(self, action: #selector(self.onTappedDeleteButton(_:)), for: .touchUpInside)
        addButton(deleteButton, R.image.circlemenu_close()!)

        // ヘッダーフィールド
        headerField.addTarget(self, action: #selector(self.onTappedHeaderField(_:)), for: .touchUpInside)
        
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
        headerField.frame = CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: headerFieldOriginY, width: AppConst.headerFieldWidth, height: AppConst.headerViewHeight * 0.5)
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
        headerField.alpha += value / (AppConst.headerViewHeight - DeviceConst.statusBarHeight)
        headerItems.forEach { (button) in
            button.alpha += value / (AppConst.headerViewHeight - DeviceConst.statusBarHeight)
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
    
    func headerViewModelDidChangeFavorite(enable: Bool) {
        if enable {
            // すでに登録済みの場合は、お気に入りボタンの色を変更する
            favoriteButton.setImage(image: R.image.header_favorite_selected(), color: UIColor.brilliantBlue)
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
                self.headerField.makeInputForm(height: self.headerFieldOriginY)
            })
        }
    }
    
// MARK: Button Event
    @objc func onTappedHistoryBackButton(_ sender: AnyObject) {
        viewModel.notifyHistoryBackWebView()
    }

    @objc func onTappedHistoryForwardButton(_ sender: AnyObject) {
        viewModel.notifyHistoryForwardWebView()
    }

    @objc func onTappedFavoriteButton(_ sender: AnyObject) {
        viewModel.notifyRegisterAsFavorite()
    }

    @objc func onTappedDeleteButton(_ sender: AnyObject) {
        viewModel.notifyRemoveWebView()
    }
    
    @objc func onTappedHeaderField(_ sender: AnyObject) {
        startEditing()
    }
}
