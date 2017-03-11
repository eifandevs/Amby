//
//  EGTextField.swift
//  Eiger
//
//  Created by tenma on 2017/03/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class EGTextField: UITextField, ShadowView {
    
    let icon = UIView()
    
    convenience init(iconSize: CGSize) {
        self.init()
        icon.frame = CGRect(origin: CGPoint.zero, size: iconSize)
        addShadow()
        font = UIFont(name: AppDataManager.shared.appFont, size: AppDataManager.shared.headerViewSizeMax / 4.8)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textAlignment = .center
        alpha = 0
        
        backgroundColor = UIColor.pastelLightGray
        
        icon.backgroundColor = UIColor.raspberry
        
        //        let iconImage = UIImageView()
        //        iconImage.backgroundColor = UIColor.raspberry
        //        icon.addSubview(iconImage)
        
        leftViewMode = .always
        leftView = icon
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
