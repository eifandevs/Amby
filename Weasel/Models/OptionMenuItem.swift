//
//  OptionMenuItem.swift
//  Weasel
//
//  Created by User on 2017/06/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

enum OptionMenuType: CGFloat {
    case plain
    case deletablePlain
    case input
    case select
}

class OptionMenuItem {
    var _id: String? = nil
    var type: OptionMenuType = .plain
    var title: String? = nil
    var url: String? = nil
    var image: UIImage? =  nil
    var date: Date? = nil
    var action: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil
    
    init(_id: String? = nil, type: OptionMenuType = .plain, title: String? = nil, url: String? = nil, image: UIImage? = nil, date: Date? = nil, action: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil) {
        self._id = _id
        self.type = type
        self.title = title
        self.url = url
        self.image = image
        self.date = date
        self.action = action
    }
}
