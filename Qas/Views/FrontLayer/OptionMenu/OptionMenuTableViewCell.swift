//
//  OptionMenuTableViewCell.swift
//  Qas
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
    private var switchControl: UISwitch = UISwitch()
    private var slider: UISlider = UISlider()
    private var menuItem: OptionMenuItem?
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
    
    func setTitle(menuItem: OptionMenuItem) {
        initialize()
        type = menuItem.type
        self.menuItem = menuItem
        switch menuItem.type {
        case .plain, .deletablePlain:
            var marginX: CGFloat = 10
            
            if let unwrappedImage = menuItem.image {
                marginX = AppConst.tableViewCellHeight + 10
                thumbnail = UIButton(frame: CGRect(x: 0, y: 0, width: AppConst.tableViewCellHeight / 1.3, height: AppConst.tableViewCellHeight / 1.3))
                thumbnail.center = CGPoint(x: marginX / 2, y: AppConst.tableViewCellHeight / 2)
                thumbnail.isUserInteractionEnabled = false
                thumbnail.setImage(image: unwrappedImage, color: UIColor.black)
                thumbnail.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
                thumbnail.layer.cornerRadius = thumbnail.bounds.size.width / 2
                thumbnail.backgroundColor = UIColor.clear
                contentView.addSubview(thumbnail)
            }
            
            if menuItem.url == nil {
                titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppConst.optionMenuSize.width - marginX, height: AppConst.tableViewCellHeight / 1.5))
                titleLabel.center.y = frame.size.height / 2
            } else {
                titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppConst.optionMenuSize.width - marginX, height: AppConst.tableViewCellHeight / 1.5))
                urlLabel.frame = CGRect(origin: CGPoint(x: marginX, y: AppConst.tableViewCellHeight / 1.5 - 3), size: CGSize(width: AppConst.optionMenuSize.width - marginX, height: AppConst.tableViewCellHeight - titleLabel.frame.size.height))
                
                // urlを配置
                urlLabel.textAlignment = .left
                urlLabel.text = menuItem.url
                urlLabel.font = UIFont(name: AppConst.appFont, size: 11)
                contentView.addSubview(urlLabel)
            }
            // titleを配置
            titleLabel.textAlignment = .left
            titleLabel.text = menuItem.title
            titleLabel.font = UIFont(name: AppConst.appFont, size: 13.5)
            contentView.addSubview(titleLabel)
        case .select:
            selectionStyle = .none
            let marginX: CGFloat = 10
            titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppConst.optionMenuSize.width / 1.5, height: AppConst.tableViewCellHeight / 1.5))
            titleLabel.center.y = frame.size.height / 2
            titleLabel.textAlignment = .left
            titleLabel.text = menuItem.title
            titleLabel.font = UIFont(name: AppConst.appFont, size: 13.5)
            contentView.addSubview(titleLabel)
            
            switchControl.frame = CGRect(origin: CGPoint(x: marginX + titleLabel.frame.size.width, y: 0), size: CGSize(width: AppConst.optionMenuSize.width - titleLabel.frame.size.width, height: AppConst.tableViewCellHeight / 3))
            switchControl.center.y = frame.size.height / 2
            switchControl.isOn = menuItem.defaultValue! as! Bool
            switchControl.onTintColor = UIColor.brilliantBlue
            switchControl.addTarget(self, action: #selector(self.onChangedSwitchValue(_:)), for: .valueChanged)
            contentView.addSubview(switchControl)
        case .slider:
            selectionStyle = .none
            let marginX: CGFloat = 10
            slider.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppConst.optionMenuSize.width - marginX * 2, height: AppConst.tableViewCellHeight / 3))
            slider.center.y = frame.size.height / 2
            slider.minimumValue = menuItem.minValue
            slider.maximumValue = menuItem.maxValue
            slider.value = menuItem.defaultValue! as! Float
            slider.isContinuous = false
            slider.tintColor = UIColor.brilliantBlue
            slider.maximumValueImage = UIColor.blue.circleImage(size: CGSize(width: 5, height: 5))
            slider.minimumValueImage = UIColor.red.circleImage(size: CGSize(width: 5, height: 5))
            slider.addTarget(self, action: #selector(self.onChangedSliderValue(_:)), for: .valueChanged)
            contentView.addSubview(slider)
        }
    }
    
    func initialize() {
        titleLabel.removeFromSuperview()
        urlLabel.removeFromSuperview()
        thumbnail.removeFromSuperview()
        switchControl.removeFromSuperview()
        slider.removeFromSuperview()
    }
    
// MARK: UISwitch Event
    func onChangedSwitchValue(_ sender: AnyObject) {
        if let menuItem = menuItem {
//            menuItem.switchAction?(switchControl.isOn)
        }
    }
    
// MARK: UISlider Event
    func onChangedSliderValue(_ sender: AnyObject) {
        if let menuItem = menuItem {
            menuItem.sliderAction?(slider.value)
        }
    }
}
