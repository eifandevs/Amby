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
    let heightMax = AppDataManager.shared.headerViewHeight
    private var headerField = EGTextField(iconSize: CGSize(width: AppDataManager.shared.headerViewHeight / 2, height: AppDataManager.shared.headerViewHeight / 2))
    private var isEditing = false
    private let viewModel = HeaderViewModel()
    private var progressBar: EGProgressBar = EGProgressBar(frame: CGRect(x: 0, y: 0, width: DeviceDataManager.shared.displaySize.width, height: 2.1), min: CGFloat(AppDataManager.shared.progressMin))
    private var historyBackButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 4, height: AppDataManager.shared.headerViewHeight)))
    private var historyForwardButton = UIButton(frame: CGRect(origin: CGPoint(x: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 4, y: 0), size: CGSize(width: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 4, height: AppDataManager.shared.headerViewHeight)))
    private var favoriteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppDataManager.shared.headerFieldWidth + (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 2, y: 0), size: CGSize(width: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 4, height: AppDataManager.shared.headerViewHeight)))
    private var deleteButton = UIButton(frame: CGRect(origin: CGPoint(x: AppDataManager.shared.headerFieldWidth + (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 4 * 3, y: 0), size: CGSize(width: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 4, height: AppDataManager.shared.headerViewHeight)))

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
            return frame.size.height != DeviceDataManager.shared.statusBarHeight && frame.size.height != heightMax
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        viewModel.delegate = self
        headerField.delegate = self
        addShadow()
        backgroundColor = UIColor.pastelLightGray
        
        /// ヘッダーアイテム
        // ヒストリバック
        historyBackButton.backgroundColor = UIColor.blue
        _ = historyBackButton.reactive.tap
            .observe { [weak self] _ in
                self!.viewModel.notifyHistoryBackWebView()
        }
        
        // ヒストリフォアード
        historyForwardButton.backgroundColor = UIColor.yellow
        _ = historyForwardButton.reactive.tap
            .observe { [weak self] _ in
                self!.viewModel.notifyHistoryForwardWebView()
        }
        
        // お気に入り登録
        favoriteButton.backgroundColor = UIColor.red
        _ = favoriteButton.reactive.tap
            .observe { [weak self] _ in
                self!.viewModel.notifyRegisterAsFavorite()
        }
        
        // 現在のWebView削除
        deleteButton.backgroundColor = UIColor.purple
        _ = deleteButton.reactive.tap
            .observe { [weak self] _ in
                self!.viewModel.notifyRemoveWebView()
        }
        
        addSubview(historyBackButton)
        addSubview(historyForwardButton)
        addSubview(favoriteButton)
        addSubview(deleteButton)
        
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
        historyBackButton.center.y = frame.size.height - heightMax * 0.5
        historyForwardButton.center.y = frame.size.height - heightMax * 0.5
        favoriteButton.center.y = frame.size.height - heightMax * 0.5
        deleteButton.center.y = frame.size.height - heightMax * 0.5
        progressBar.frame.origin.y = frame.size.height - 2.1
        if !isEditing {
            headerField.frame = CGRect(x: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppDataManager.shared.headerFieldWidth, height: heightMax * 0.5)
        }
    }
    
    func resizeToMax() {
        frame.size.height = heightMax
        historyBackButton.center.y = frame.size.height - heightMax * 0.5
        historyForwardButton.center.y = frame.size.height - heightMax * 0.5
        favoriteButton.center.y = frame.size.height - heightMax * 0.5
        deleteButton.center.y = frame.size.height - heightMax * 0.5
        progressBar.frame.origin.y = frame.size.height - 2.1
        headerField.frame = CGRect(x: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppDataManager.shared.headerFieldWidth, height: heightMax * 0.5)
        headerField.alpha = 1
    }
    
    func resizeToMin() {
        frame.size.height = DeviceDataManager.shared.statusBarHeight
        historyBackButton.center.y = frame.size.height - heightMax * 0.5
        historyForwardButton.center.y = frame.size.height - heightMax * 0.5
        favoriteButton.center.y = frame.size.height - heightMax * 0.5
        deleteButton.center.y = frame.size.height - heightMax * 0.5
        progressBar.frame.origin.y = frame.size.height - 2.1
        headerField.frame = CGRect(x: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppDataManager.shared.headerFieldWidth, height: heightMax * 0.5)
        headerField.alpha = 0
    }
    
    func finishEditing(force: Bool) {
        if force {
            headerField.removeInputForm()
            
            headerField.frame = CGRect(x: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppDataManager.shared.headerFieldWidth, height: heightMax * 0.5)
            self.isEditing = false
            self.headerField.makeContent(restore: true, restoreText: nil)
        } else {
            let text = headerField.textField?.text
            headerField.removeInputForm()
            
            headerField.frame = CGRect(x: (DeviceDataManager.shared.displaySize.width - AppDataManager.shared.headerFieldWidth) / 2, y: frame.size.height - heightMax * 0.63, width: AppDataManager.shared.headerFieldWidth, height: heightMax * 0.5)
            self.isEditing = false
            
            if let text = text, !text.isEmpty {
                let restoreText = text.hasValidUrl ? text : "\(AppDataManager.shared.searchPath)\(text)"
                let encodedText = restoreText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

                self.headerField.makeContent(restore: true, restoreText: encodedText)
            } else {
                self.headerField.makeContent(restore: true, restoreText: nil)
            }
        }
    }
    
    func resize(value: CGFloat) {
        frame.size.height += value
        headerField.alpha += value / (heightMax - DeviceDataManager.shared.statusBarHeight)
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
}
