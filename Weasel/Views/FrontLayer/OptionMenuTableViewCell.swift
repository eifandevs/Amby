//
//  OptionMenuTableViewCell.swift
//  Weasel
//
//  Created by User on 2017/06/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class OptionMenuTableViewCell: UITableViewCell {
    var titleLabel: UILabel = UILabel()
    var urlLabel: UILabel = UILabel()
    var thumbnail: UIImageView = UIImageView()
    
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
    
    func setTitle(title: String?, url: String?, image: UIImage?) {
        initialize()
        var marginX: CGFloat = 10
        
        if let unwrappedImage = image {
            marginX = AppDataManager.shared.optionMenuCellHeight
            thumbnail = UIImageView(frame: CGRect(x: 0, y: 0, width: AppDataManager.shared.optionMenuCellHeight, height: AppDataManager.shared.optionMenuCellHeight))
            thumbnail.image = unwrappedImage
            thumbnail.backgroundColor = UIColor.black
            contentView.addSubview(thumbnail)
        }
        
        if url == nil {
            titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX, height: AppDataManager.shared.optionMenuCellHeight / 1.5))
            titleLabel.center.y = frame.size.height / 2
        } else {
            titleLabel.frame = CGRect(origin: CGPoint(x: marginX, y: 0), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX, height: AppDataManager.shared.optionMenuCellHeight / 1.5))
            urlLabel.frame = CGRect(origin: CGPoint(x: marginX, y: AppDataManager.shared.optionMenuCellHeight / 1.5 - 3), size: CGSize(width: AppDataManager.shared.optionMenuSize.width - marginX, height: AppDataManager.shared.optionMenuCellHeight - titleLabel.frame.size.height))
        }
        titleLabel.textAlignment = .left
        titleLabel.text = title
        titleLabel.font = UIFont(name: AppDataManager.shared.appFont, size: 15)
        
        urlLabel.textAlignment = .left
        urlLabel.text = url
        urlLabel.font = UIFont(name: AppDataManager.shared.appFont, size: 12)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(urlLabel)
    }
    
    func initialize() {
        titleLabel.removeFromSuperview()
        urlLabel.removeFromSuperview()
        thumbnail.removeFromSuperview()
    }
}
