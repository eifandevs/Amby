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

class HeaderView: UIView, UITextFieldDelegate, HeaderViewModelDelegate, ShadowView {
    
    var delegate: HeaderViewDelegate?
    let heightMax = AppConst.headerViewHeight
    private var headerField = EGTextField(iconSize: CGSize(width: AppConst.headerViewHeight / 2, height: AppConst.headerViewHeight / 2))
    private var isEditing = false
    private let viewModel = HeaderViewModel()
    private var progressBar: EGProgressBar = EGProgressBar(frame: CGRect(x: 0, y: 0, width: DeviceConst.displaySize.width, height: 2.1), min: CGFloat(AppConst.progressMin))
    private var historyBackButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4, height: AppConst.headerViewHeight)))
    private var historyForwardButton = UIButton(frame: CGRect(origin: CGPoint(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4, y: 0), size: CGSize(width: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4, height: AppConst.headerViewHeight)))
    private var favoriteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.headerFieldWidth + (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: 0), size: CGSize(width: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4, height: AppConst.headerViewHeight)))
    private var deleteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppConst.headerFieldWidth + (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4 * 3, y: 0), size: CGSize(width: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 4, height: AppConst.headerViewHeight)))

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
    
    var resizing: Bool {
        get {
            return frame.size.height != DeviceConst.statusBarHeight && frame.size.height != heightMax
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        viewModel.delegate = self
        headerField.delegate = self
        addShadow()
        backgroundColor = UIColor.pastelLightGray
        
        /// ヘッダーアイテム
        let addButton = { (button: UIButton, image: UIImage, action: @escaping (() -> ())) -> Void in
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            button.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(tintedImage, for: .normal)
            button.alpha = 0
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
                self!.isEditing = true
                self!.headerField.removeContent()
                self!.delegate?.headerViewDidBeginEditing()
                UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                    self!.headerField.frame = self!.frame
                }, completion: { _ in
                    // キーボード表示
                    self!.headerField.makeInputForm(height: self!.frame.size.height - self!.heightMax * 0.63)
                })
        }
        
        addSubview(headerField)
        addSubview(progressBar)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        headerItems.forEach { (button) in
            button.center.y = frame.size.height - heightMax * 0.5
        }
        progressBar.frame.origin.y = frame.size.height - 2.1
        if !isEditing {
            headerField.frame = CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.66, width: AppConst.headerFieldWidth, height: heightMax * 0.5)
        }
    }
    
    func resizeToMax() {
        frame.size.height = heightMax
        headerItems.forEach { (button) in
            button.center.y = frame.size.height - heightMax * 0.5
            button.alpha = 1
        }
        progressBar.frame.origin.y = frame.size.height - 2.1
        headerField.frame = CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppConst.headerFieldWidth, height: heightMax * 0.5)
        headerField.alpha = 1
    }
    
    func resizeToMin() {
        frame.size.height = DeviceConst.statusBarHeight
        headerItems.forEach { (button) in
            button.center.y = frame.size.height - heightMax * 0.5
            button.alpha = 0
        }
        progressBar.frame.origin.y = frame.size.height - 2.1
        headerField.frame = CGRect(x: (DeviceConst.displaySize.width - AppConst.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppConst.headerFieldWidth, height: heightMax * 0.5)
        headerField.alpha = 0
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
    
    func resize(value: CGFloat) {
        frame.size.height += value
        headerField.alpha += value / (heightMax - DeviceConst.statusBarHeight)
        headerItems.forEach { (button) in
            button.alpha += value / (heightMax - DeviceConst.statusBarHeight)
        }
    }
    
// MARK: UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.headerViewDidEndEditing()
        
        if let text = textField.text, !text.isEmpty {
            let encodedText = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            viewModel.notifySearchWebView(text: encodedText!)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
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
}
