//
//  HeaderView.swift
//  Eiger
//
//  Created by tenma on 2017/03/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class HeaderView: UIView, ShadowView {
    
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
    
    override init(frame: CGRect) {
        headerField = EGTextField(iconSize: CGSize(width: heightMax / 2, height: heightMax / 2))
        super.init(frame: frame)
        addShadow()
        backgroundColor = UIColor.pastelLightGray
        
        _ = headerField.reactive.controlEvents(.touchUpInside)
            .observeNext { [weak self] _ in
                self!.isEditing = true
                UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                    self!.headerField.frame = self!.frame
                }, completion: { _ in
                    // キーボード表示
                })
                self!.headerField.removeContent()
                let overlay = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: self!.frame.size.height), size: CGSize(width: self!.superview!.frame.size.width, height: self!.superview!.frame.size.height - self!.frame.size.height)))
                overlay.backgroundColor = UIColor.gray
                _ = overlay.reactive.controlEvents(.touchDown)
                    .observeNext { [weak self] _ in
                        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                            self!.headerField.frame = CGRect(x: 95, y: self!.frame.size.height - self!.heightMax * 0.63, width: self!.superview!.frame.size.width - 190, height: self!.heightMax * 0.5)
                        }, completion: { _ in
                            self!.isEditing = false
                            self!.headerField.makeContent(restore: true, restoreText: nil)
                        })
                        overlay.removeFromSuperview()
                }
                self!.superview!.addSubview(overlay)
        }
        
        addSubview(headerField)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resizeToMax() {
        frame.size.height = heightMax
        headerField.frame = CGRect(x: 95, y: frame.size.height - frame.size.height * 0.63, width: superview!.frame.size.width - 190, height: heightMax * 0.5)
        headerField.alpha = 1
    }
    
    func resizeToMin() {
        frame.size.height = DeviceDataManager.shared.statusBarHeight
        headerField.frame = CGRect(x: 95, y: frame.size.height - frame.size.height * 0.63, width: superview!.frame.size.width - 190, height: heightMax * 0.5)
        headerField.alpha = 0
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
}
