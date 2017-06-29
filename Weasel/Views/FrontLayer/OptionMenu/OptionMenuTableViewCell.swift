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
    private var titleLabel: UILabel = UILabel()
    private var urlLabel: UILabel = UILabel()
    private var thumbnail: UIButton = UIButton()
    private var textField: OptionMenuTextField = OptionMenuTextField()
    private var switchControl: UISwitch = UISwitch()
    private var slider: UISlider = UISlider()
    private var type: OptionMenuType = .plain
    
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
    
    deinit {
        if type == .input {
            NotificationCenter.default.removeObserver(self)
        }
    }
        
    func setTitle(menuItem: OptionMenuItem) {
        initialize()
        type = menuItem.type
        switch menuItem.type {
        case .plain, .deletablePlain:
            var marginX: CGFloat = 10
            
            if let unwrappedImage = menuItem.image {
                marginX = AppDataManager.shared.optionMenuCellHeight + 10
                thumbnail = UIButton(frame: CGRect(x: 0, y: 0, width: AppDataManager.shared.optionMenuCellHeight / 1.3, height: AppDataManager.shared.optionMenuCellHeight / 1.3))
                thumbnail.center = CGPoint(x: marginX / 2, y: AppDataManager.shared.optionMenuCellHeight / 2)
                thumbnail.isUserInteractionEnabled = false
                let tintedImage = unwrappedImage.withRenderingMode(.alwaysTemplate)
                thumbnail.setImage(tintedImage, for: .normal)
                thumbnail.imageView?.contentMode = .scaleAspectFit
                thumbnail.tintColor = UIColor.black
                thumbnail.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
                thumbnail.layer.cornerRadius = thumbnail.bounds.size.width / 2
                thumbnail.backgroundColor = UIColor.clear
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
                urlLabel.font = UIFont(name: AppDataManager.shared.appFont, size: 11)
                contentView.addSubview(urlLabel)
            }
            // titleを配置
            titleLabel.textAlignment = .left
            titleLabel.text = menuItem.title
            titleLabel.font = UIFont(name: AppDataManager.shared.appFont, size: 13.5)
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
            
            switchControl.frame = CGRect(origin: CGPoint(x: marginX + titleLabel.frame.size.width, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - titleLabel.frame.size.width, height: AppDataManager.shared.optionMenuCellHeight / 3))
            switchControl.center.y = frame.size.height / 2
            switchControl.onTintColor = UIColor.frenchBlue
            contentView.addSubview(switchControl)
        case .slider:
            selectionStyle = .none
            let marginX: CGFloat = 10
            slider.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX * 2, height: AppDataManager.shared.optionMenuCellHeight / 3))
            slider.center.y = frame.size.height / 2
            slider.minimumValue = -0.07
            slider.maximumValue = -0.01
            slider.value = -UserDefaults.standard.float(forKey: AppDataManager.shared.autoScrollIntervalKey)
            slider.isContinuous = false
            slider.maximumValueImage = UIColor.blue.circleImage(size: CGSize(width: 5, height: 5))
            slider.minimumValueImage = UIColor.red.circleImage(size: CGSize(width: 5, height: 5))
            slider.addTarget(self, action: #selector(changeSlider), for: .valueChanged)
            contentView.addSubview(slider)
        }
    }
    
    func initialize() {
        titleLabel.removeFromSuperview()
        urlLabel.removeFromSuperview()
        thumbnail.removeFromSuperview()
        textField.removeFromSuperview()
        switchControl.removeFromSuperview()
        slider.removeFromSuperview()
    }

// MARK: UISliderDelegate
    func changeSlider(sender: UISlider) {
        UserDefaults.standard.set(-sender.value, forKey: AppDataManager.shared.autoScrollIntervalKey)
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
