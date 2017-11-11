//
//  OptionMenuItem.swift
//  Qas
//
//  Created by User on 2017/06/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

enum OptionMenuType: CGFloat {
    case plain
    case deletablePlain
    case select
    case slider
}

class OptionMenuItem {
    var _id: String? = nil
    var type: OptionMenuType = .plain
    var title: String? = nil
    var url: String? = nil
    var image: UIImage? =  nil
    var date: Date? = nil
    var action: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil
    var sliderAction: ((Float) -> ())? = nil
    var defaultValue: Any? = nil
    var minValue: Float = 0
    var maxValue: Float = 0
    
    
    init(_id: String? = nil, type: OptionMenuType = .plain, title: String? = nil, url: String? = nil, image: UIImage? = nil, date: Date? = nil, action: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil, sliderAction: ((Float) -> ())? = nil, defaultValue: Any? = nil, minValue: Float = 0, maxValue: Float = 0) {
        self._id = _id
        self.type = type
        self.title = title
        self.url = url
        self.image = image
        self.date = date
        self.action = action
        self.sliderAction = sliderAction
        self.defaultValue = defaultValue
        self.minValue = minValue
        self.maxValue = maxValue
    }
}
