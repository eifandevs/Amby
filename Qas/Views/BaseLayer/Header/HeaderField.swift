//
//  EGTextField.swift
//  Eiger
//
//  Created by tenma on 2017/03/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol HeaderFieldDelegate {
    func headerFieldDidEndEditing(text: String?)
}

class HeaderField: UIButton, ShadowView, UITextFieldDelegate {
    var delegate: HeaderFieldDelegate?
    private var icon: UIImageView? = nil
    private let iconSize: CGSize = CGSize(width: AppConst.headerViewHeight / 2, height: AppConst.headerViewHeight / 2)
    private var label: EGGradientLabel? = nil
    private var pastLabelText: String? = nil
    private let fontSize: CGFloat = 15
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
                icon.frame.size = iconSize
            } else {
                icon.frame.size = CGSize.zero
            }
            // テキストフィールドがちらつくので、ラベルを再生成する
            self.label!.removeFromSuperview()
            self.label! = EGGradientLabel()
            self.label!.isUserInteractionEnabled = false
            self.label!.numberOfLines = 1
            self.label!.frame = CGRect(x: 0, y: 0, width: frame.size.width - icon.frame.size.width, height: frame.size.height)
            let isHttpRequest = !value.isEmpty && icon.frame.size.width == 0
            self.label!.attributedText = attribute(text: isHttpRequest ? "   \(value)" : value)
            addSubview(self.label!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadow()
        
        backgroundColor = UIColor.white
        alpha = 1
        makeContent(restore: false, restoreText: nil)
    }
    
    func reduction(frame: CGRect) {
        self.frame = frame
        textField.frame.size.width = textField.frame.size.width + 40
    }
    // ヘッダービューをタップしたらコールされる
    // それまで、テキストフィールドは表示しない
    func makeInputForm(height: CGFloat) {
        let closeMenuButtonWidth: CGFloat = frame.size.width / 8.28
        textField = UITextField(frame: CGRect(origin: CGPoint(x: 5, y: height), size: CGSize(width: frame.size.width - closeMenuButtonWidth, height: iconSize.height)))
        textField.borderStyle = .none
        textField.keyboardType = .default
        textField.returnKeyType = .search
        textField.delegate = self
        textField.placeholder = "検索ワードまたは、URLを入力"
        textField.text = pastLabelText
        textField.clearButtonMode = .always
        
        // 削除ボタン作成
        let closeMenuButton = UIButton(frame: CGRect(x: textField.frame.size.width, y: 0, width: closeMenuButtonWidth, height: self.frame.size.height))
        closeMenuButton.setImage(image: R.image.header_close(), color: UIColor.gray)
        let edgeInset: CGFloat = closeMenuButtonWidth / 8.333
        closeMenuButton.imageEdgeInsets = UIEdgeInsetsMake(edgeInset + 14, edgeInset, edgeInset, edgeInset)
        _ = closeMenuButton.reactive.tap
            .observe { _ in
                self.delegate?.headerFieldDidEndEditing(text: nil)
        }
        self.addSubview(closeMenuButton)
        
        textField.becomeFirstResponder()
        addSubview(textField)
    }

    // テキストフィールドの削除
    func removeInputForm() {
        closeKeyBoard()
        textField.removeFromSuperview()
        textField = nil
    }
    
    // キーボードの削除
    func closeKeyBoard() {
        textField.endEditing(true)
    }
    
    // ヘッダービューのコンテンツを作成(テキストフィールドではない)
    func makeContent(restore: Bool, restoreText: String?) {
        icon = UIImageView()
        icon?.setImage(image: R.image.key(), color: UIColor.lightGreen)
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
            icon.frame.size = iconSize
        } else {
            icon.frame.size = CGSize.zero
        }
        label.frame = CGRect(x: icon.frame.size.width, y: 0, width: frame.size.width - icon.frame.size.width, height: frame.size.height)
    }
    
    private func attribute(text: String) -> NSMutableAttributedString? {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        style.alignment = NSTextAlignment.left
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let attr = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: AppConst.appFont, size: fontSize)!,
            NSParagraphStyleAttributeName: style,
            ] as [String : Any]
        
        let mString = NSMutableAttributedString(string: text, attributes: attr)
        mString.addAttribute(
            NSForegroundColorAttributeName,
            value: UIColor.lightGreen,
            range: (text as NSString).range(of: "https"))

        return mString
    }

// MARK: UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.headerFieldDidEndEditing(text: textField.text)
        
        return true
    }

}
