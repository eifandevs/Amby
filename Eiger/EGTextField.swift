//
//  EGTextField.swift
//  Eiger
//
//  Created by tenma on 2017/03/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class EGTextField: UIButton, ShadowView {
    
    private var icon: UIImageView? = nil
    private var size: CGSize = CGSize.zero
    private var label: EGGradientLabel? = nil
    private var pastLabelText: String? = nil
    private let fontSize: CGFloat = 15
    var delegate : UITextFieldDelegate? = nil
    var textField: UITextField! = nil
    
    var text: String? {
        get {
            return label?.attributedText?.string
        }
        set {
            guard let value = newValue, let icon = icon, let label = label else {
                return
            }
            if let value = newValue, value.hasHttpsUrl {
                icon.frame.size = size
            } else {
                icon.frame.size = CGSize.zero
            }
            label.frame = CGRect(x: icon.frame.size.width, y: 0, width: frame.size.width - icon.frame.size.width, height: frame.size.height)
            label.attributedText = attribute(text: value)
        }
    }
    
    convenience init(iconSize: CGSize) {
        self.init()
        addShadow()
        
        size = iconSize
        backgroundColor = UIColor.white
        alpha = 0
        makeContent(restore: false, restoreText: nil)
    }
    
    // ヘッダービューをタップしたらコールされる
    // それまで、テキストフィールドは表示しない
    func makeInputForm(height: CGFloat) {
        textField = UITextField(frame: CGRect(origin: CGPoint(x: 5, y: height), size: CGSize(width: frame.size.width - 10, height: size.height)))
        textField.borderStyle = .none
        textField.keyboardType = .default
        textField.delegate = delegate
        textField.placeholder = "検索 / URL / 位置検索(@)"
        textField.text = pastLabelText
        textField.becomeFirstResponder()
        addSubview(textField)
    }
    
    // テキストフィールドの削除
    func removeInputForm() {
        textField.endEditing(true)
        textField.removeFromSuperview()
        textField = nil
    }
    
    // ヘッダービューのコンテンツを作成(テキストフィールドではない)
    func makeContent(restore: Bool, restoreText: String?) {
        icon = UIImageView()
        icon!.backgroundColor = UIColor.raspberry
        icon?.isUserInteractionEnabled = false
        addSubview(icon!)
        
        label = EGGradientLabel()
        label?.isUserInteractionEnabled = false
        label!.numberOfLines = 1
        // 復元フラグが立っていれば、前回状態で作成する
        if let _pastLabelText = pastLabelText, restore {
            if let restoreText = restoreText {
                text = restoreText
            } else {
                text = _pastLabelText
            }
            pastLabelText = nil
        }
        addSubview(label!)
    }
    
    func removeContent() {
        if let text = label?.text {
            pastLabelText = text
        }
        icon?.removeFromSuperview()
        icon = nil
        label?.removeFromSuperview()
        label = nil
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        guard let icon = icon, let label = label else {
            return
        }
        if let text = text, text.hasHttpsUrl {
            icon.frame.size = size
        } else {
            icon.frame.size = CGSize.zero
        }
        label.frame = CGRect(x: icon.frame.size.width, y: 0, width: frame.size.width - icon.frame.size.width, height: frame.size.height)
    }
    
    private func attribute(text: String) -> NSMutableAttributedString? {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = NSTextAlignment.left
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let attr = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: AppDataManager.shared.appFont, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
            NSParagraphStyleAttributeName: style,
            ] as [String : Any]
        
        let mString = NSMutableAttributedString(string: text, attributes: attr)
        mString.addAttribute(
            NSForegroundColorAttributeName,
            value: UIColor.blue,
            range: (text as NSString).range(of: "https"))

        return mString
    }
}
