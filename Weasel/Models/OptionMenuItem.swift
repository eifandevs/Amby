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
    case input
    case select
}

class OptionMenuItem {
    var type: OptionMenuType = .plain
    var title: String? = nil
    var url: String? = nil
    var image: UIImage? =  nil
    var action: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil
    
    init(type: OptionMenuType = .plain, title: String? = nil, url: String? = nil, image: UIImage? = nil, action: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil) {
        self.type = type
        self.title = title
        self.url = url
        self.image = image
        self.action = action
    }
}
