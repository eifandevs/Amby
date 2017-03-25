//
//  HeaderView.swift
//  Eiger
//
//  Created by tenma on 2017/03/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol HeaderViewDelegate {
    func headerViewDidBeginEditing()
    func headerViewDidEndEditing(text: String?)
}

class HeaderView: UIView, UITextFieldDelegate, ShadowView {
    
    var delegate: HeaderViewDelegate?

    let heightMax: CGFloat = 65
    
    private var headerField: EGTextField! = nil
    private var isEditing = false
    

    var text: String? {
        get {
            return headerField.text
        }
        set {
            headerField.text = newValue
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
            return frame.size.height != DeviceDataManager.shared.statusBarHeight && frame.size.height != heightMax
        }
    }
    
    init() {
        headerField = EGTextField(iconSize: CGSize(width: heightMax / 2, height: heightMax / 2))
        super.init(frame: CGRect.zero)
        addShadow()
        backgroundColor = UIColor.pastelLightGray
        
        _ = headerField.reactive.controlEvents(.touchUpInside)
            .observeNext { [weak self] _ in
                self!.isEditing = true
                UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                    self!.headerField.frame = self!.frame
                }, completion: { _ in
                    // キーボード表示
                    self!.headerField.makeInputForm(height: self!.frame.size.height - self!.heightMax * 0.63, obj: self!)
                })
                self!.headerField.removeContent()
                self!.delegate?.headerViewDidBeginEditing()
        }
        
        addSubview(headerField)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resizeToMax() {
        frame.size.height = heightMax
        headerField.frame = CGRect(x: 95, y: frame.size.height - heightMax * 0.63, width: superview!.frame.size.width - 190, height: heightMax * 0.5)
        headerField.alpha = 1
    }
    
    func resizeToMin() {
        frame.size.height = DeviceDataManager.shared.statusBarHeight
        headerField.frame = CGRect(x: 95, y: frame.size.height - heightMax * 0.63, width: superview!.frame.size.width - 190, height: heightMax * 0.5)
        headerField.alpha = 0
    }
    
    func finishEditing(force: Bool) {
        if force {
            headerField.removeInputForm()
            
            self.headerField.frame = CGRect(x: 95, y: self.frame.size.height - self.heightMax * 0.63, width: self.superview!.frame.size.width - 190, height: self.heightMax * 0.5)
            self.isEditing = false
            self.headerField.makeContent(restore: true, restoreText: nil)
        } else {
            let text = headerField.textField?.text
            headerField.removeInputForm()
            
            self.headerField.frame = CGRect(x: 95, y: self.frame.size.height - self.heightMax * 0.63, width: self.superview!.frame.size.width - 190, height: self.heightMax * 0.5)
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
    
    override func layoutSubviews() {
        if !isEditing {
            headerField.frame = CGRect(x: 95, y: frame.size.height - heightMax * 0.63, width: superview!.frame.size.width - 190, height: heightMax * 0.5)
        }
    }
    
// MARK: UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.headerViewDidEndEditing(text: textField.text)
        return true
    }
}
