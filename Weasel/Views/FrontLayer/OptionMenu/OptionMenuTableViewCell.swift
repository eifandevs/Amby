//
//  OptionMenuTableViewCell.swift
//  Weasel
//
//  Created by User on 2017/06/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class OptionMenuTableViewCell: UITableViewCell, UITextFieldDelegate {
    var titleLabel: UILabel = UILabel()
    var urlLabel: UILabel = UILabel()
    var thumbnail: UIImageView = UIImageView()
    var textField: OptionMenuTextField = OptionMenuTextField()
    var switchControl: UISwitch = UISwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setTitle(menuItem: OptionMenuItem) {
        initialize()
        
        switch menuItem.type {
        case .plain:
            var marginX: CGFloat = 10
            
            if let unwrappedImage = menuItem.image {
                marginX = AppDataManager.shared.optionMenuCellHeight
                thumbnail = UIImageView(frame: CGRect(x: 0, y: 0, width: AppDataManager.shared.optionMenuCellHeight, height: AppDataManager.shared.optionMenuCellHeight))
                thumbnail.image = unwrappedImage
                thumbnail.backgroundColor = UIColor.black
                contentView.addSubview(thumbnail)
            }
            
            if menuItem.url == nil {
                titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX, height: AppDataManager.shared.optionMenuCellHeight / 1.5))
                titleLabel.center.y = frame.size.height / 2
            } else {
                titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX, height: AppDataManager.shared.optionMenuCellHeight / 1.5))
                urlLabel.frame = CGRect(origin: CGPoint(x: marginX, y: AppDataManager.shared.optionMenuCellHeight / 1.5 - 3), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX, height: AppDataManager.shared.optionMenuCellHeight - titleLabel.frame.size.height))
                
                // urlを配置
                urlLabel.textAlignment = .left
                urlLabel.text = menuItem.url
                urlLabel.font = UIFont(name: AppDataManager.shared.appFont, size: 12)
                contentView.addSubview(urlLabel)
            }
            // titleを配置
            titleLabel.textAlignment = .left
            titleLabel.text = menuItem.title
            titleLabel.font = UIFont(name: AppDataManager.shared.appFont, size: 15)
            contentView.addSubview(titleLabel)
        case .input:
            selectionStyle = .none
            let marginX: CGFloat = 10
            textField.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX * 2, height: AppDataManager.shared.optionMenuCellHeight / 1.5))
            textField.center.y = frame.size.height / 2
            textField.text = UserDefaults.standard.string(forKey: AppDataManager.shared.defaultUrlKey)!
            textField.font = UIFont(name: AppDataManager.shared.appFont, size: 14)
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.delegate = self
            registerForKeyboardWillHideNotification { [weak self] (notification) in
                if !self!.textField.edited {
                    self!.textField.text = UserDefaults.standard.string(forKey: AppDataManager.shared.defaultUrlKey)!
                } else {
                    self!.textField.edited = false
                }
            }
            contentView.addSubview(textField)
        case .select:
            selectionStyle = .none
            let marginX: CGFloat = 10
            titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width / 1.5, height: AppDataManager.shared.optionMenuCellHeight / 1.5))
            titleLabel.center.y = frame.size.height / 2
            titleLabel.textAlignment = .left
            titleLabel.text = menuItem.title
            titleLabel.font = UIFont(name: AppDataManager.shared.appFont, size: 13.5)
            contentView.addSubview(titleLabel)
            
            switchControl.frame = CGRect(origin: CGPoint(x: marginX + titleLabel.frame.size.width, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - titleLabel.frame.size.width, height: titleLabel.frame.size.height))
            switchControl.center.y = frame.size.height / 2
//            switchControl.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
            switchControl.onTintColor = UIColor.frenchBlue
            contentView.addSubview(switchControl)
        }
    }
    
    func initialize() {
        titleLabel.removeFromSuperview()
        urlLabel.removeFromSuperview()
        thumbnail.removeFromSuperview()
        textField.removeFromSuperview()
        switchControl.removeFromSuperview()
    }
    
// MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            // 有効なURLが設定されている場合に、保存する
            if (self.textField.text?.hasValidUrl)! {
                UserDefaults.standard.set(self.textField.text, forKey: AppDataManager.shared.defaultUrlKey)
                self.textField.edited = true
            }
            self.textField.resignFirstResponder()
            return false
        }
        return true
    }
}
