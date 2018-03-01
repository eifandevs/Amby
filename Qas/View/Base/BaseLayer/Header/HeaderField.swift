//
//  EGTextField.swift
//  Eiger
//
//  Created by tenma on 2017/03/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

protocol HeaderFieldDelegate: class {
    func headerFieldDidEndEditing(text: String?)
}

class HeaderField: UIButton, ShadowView {
    weak var delegate: HeaderFieldDelegate?
    private var icon: UIImageView?
    private let iconSize: CGSize = CGSize(width: AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT, height: AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT)
    private var label: EGGradientLabel?
    private var pastLabelText: String?
    private let viewModel = HeaderFieldViewModel()
    var textField: UITextField!
    
    var text: String? {
        get {
            return label?.attributedText?.string
        }
        set {
            guard let value = newValue, let icon = icon, let _ = label else {
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
            if isHttpRequest {
                self.label?.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 3)
            } else {
                self.label?.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
            }
            self.label!.attributedText = attribute(text: value)
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
        textField.frame.size.width += 40
    }
    // ヘッダービューをタップしたらコールされる
    // それまで、テキストフィールドは表示しない
    func makeInputForm(height: CGFloat) {
        let closeMenuButtonWidth: CGFloat = frame.size.width / 8.28
        textField = UITextField(frame: CGRect(origin: CGPoint(x: 5, y: height), size: CGSize(width: frame.size.width - closeMenuButtonWidth, height: iconSize.height)))
        textField.borderStyle = .none
        textField.keyboardType = .default
        textField.returnKeyType = .search
        textField.placeholder = MessageConst.HEADER_SEARCH_PLACEHOLDER
        textField.text = pastLabelText
        textField.clearButtonMode = .always
        
        // テキストフィールドの変更監視
        textField.rx.text.asDriver()
         .drive(onNext: { [weak self] text in
            guard let `self` = self else { return }
            // 表示している履歴情報の更新
            self.viewModel.executeOperationDataModel(operation: .suggest, object: text!)
         })
         .disposed(by: rx.disposeBag)
        
        // テキストフィールドの編集開始を監視
        textField.rx.controlEvent(UIControlEvents.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.textField.selectedTextRange = self.textField.textRange(from: self.textField.beginningOfDocument, to: self.textField.endOfDocument)
            })
            .disposed(by: rx.disposeBag)
        
        // テキストフィールドの編集終了を監視
        textField.rx.controlEvent(UIControlEvents.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.headerFieldDidEndEditing(text: self.textField.text)
            })
            .disposed(by: rx.disposeBag)
        
        // 削除ボタン作成
        let closeMenuButton = UIButton(frame: CGRect(x: textField.frame.size.width + 5, y: DeviceConst.STATUS_BAR_HEIGHT, width: closeMenuButtonWidth, height: self.frame.size.height - DeviceConst.STATUS_BAR_HEIGHT))
        closeMenuButton.setImage(image: R.image.header_close(), color: UIColor.gray)
        let edgeInset: CGFloat = closeMenuButtonWidth / 8.333
        closeMenuButton.imageView?.contentMode = .scaleAspectFit
        closeMenuButton.imageEdgeInsets = UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset)
        
        // ボタンタップ
        closeMenuButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.headerFieldDidEndEditing(text: nil)

            })
            .disposed(by: rx.disposeBag)
        
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
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let attr: [NSAttributedStringKey : Any] = [
            .foregroundColor : UIColor.black,
            .font : UIFont(name: AppConst.APP_FONT, size: frame.size.height / 2.5)!,
            .paragraphStyle: style
        ]
        
        let mString = NSMutableAttributedString(string: text, attributes: attr)
        mString.addAttribute(
            NSAttributedStringKey.foregroundColor,
            value: UIColor.lightGreen,
            range: (text as NSString).range(of: "https"))

        return mString
    }
}
