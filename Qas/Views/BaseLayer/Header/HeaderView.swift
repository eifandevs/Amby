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

protocol HeaderViewDelegate {
    func headerViewDidBeginEditing()
    func headerViewDidEndEditing()
}

class HeaderView: UIView, HeaderViewModelDelegate, HeaderFieldDelegate, ShadowView {
    var delegate: HeaderViewDelegate?
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
        headerField = HeaderField(frame: CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppConst.headerFieldWidth, height: heightMax * 0.5))
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
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            button.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(tintedImage, for: .normal)
            button.alpha = 1
            button.imageEdgeInsets = UIEdgeInsetsMake(18, 6.5, 6.5, 6.5)
            _ = button.reactive.tap
                .observe { _ in
                    action()
            }
            self.addSubview(button)
        }
        
        // ヒストリバック
        addButton(historyBackButton, #imageLiteral(resourceName: "historyback_webview")) { [weak self] _ in
            self!.viewModel.notifyHistoryBackWebView()
        }
        
        // ヒストリフォアード
        addButton(historyForwardButton, #imageLiteral(resourceName: "historyforward_webview")) { [weak self] _ in
            self!.viewModel.notifyHistoryForwardWebView()
        }
        
        // お気に入り登録
        addButton(favoriteButton, #imageLiteral(resourceName: "header_favorite")) { [weak self] _ in
            self!.viewModel.notifyRegisterAsFavorite()
        }
        // 現在のWebView削除
        addButton(deleteButton, #imageLiteral(resourceName: "delete_webview"), { [weak self] _ in
            self!.viewModel.notifyRemoveWebView()
        })
        
        _ = headerField.reactive.controlEvents(.touchUpInside)
            .observeNext { [weak self] _ in
                self!.startEditing()
        }
        
        addSubview(headerField)
        addSubview(progressBar)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func finishEditing(force: Bool) {
        if force {
            headerField.removeInputForm()
            
            headerField.frame = CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppConst.headerFieldWidth, height: heightMax * 0.5)
            self.isEditing = false
            self.headerField.makeContent(restore: true, restoreText: nil)
        } else {
            let text = headerField.textField?.text
            headerField.removeInputForm()
            
            headerField.frame = CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppConst.headerFieldWidth, height: heightMax * 0.5)
            self.isEditing = false
            
            if let text = text, !text.isEmpty {
                let restoreText = text.hasValidUrl ? text : "\(AppConst.searchPath)\(text)"
                let encodedText = restoreText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

                self.headerField.makeContent(restore: true, restoreText: encodedText)
            } else {
                self.headerField.makeContent(restore: true, restoreText: nil)
            }
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
        self.delegate?.headerViewDidEndEditing()
        
        if let text = text, !text.isEmpty {
            let encodedText = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            viewModel.notifySearchWebView(text: encodedText!)
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
        var tintedImage: UIImage? = nil
        if changed {
            // すでに登録済みの場合は、お気に入りボタンの色を変更する
            tintedImage = #imageLiteral(resourceName: "header_favorite_selected").withRenderingMode(.alwaysTemplate)
            favoriteButton.tintColor = UIColor.frenchBlue
        } else {
            tintedImage = #imageLiteral(resourceName: "header_favorite").withRenderingMode(.alwaysTemplate)
            favoriteButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        favoriteButton.setImage(tintedImage, for: .normal)
    }
    
    func headerViewModelDidBeginEditing() {
        // 自動で編集状態にする
        if headerField.text.isEmpty {
            startEditing()
        }
    }
    
    func startEditing() {
        if !isEditing {
            isEditing = true
            headerField.removeContent()
            delegate?.headerViewDidBeginEditing()
            UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                self.headerField.frame = self.frame
            }, completion: { _ in
                // キーボード表示
                self.headerField.makeInputForm(height: self.frame.size.height - self.heightMax * 0.63)
            })
        }
    }
}
