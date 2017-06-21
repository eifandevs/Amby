//
//  OptionMenuItem.swift
//  Weasel
//
//  Created by User on 2017/06/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class OptionMenuItem {
    var title: String? = nil
    var url: String? = nil
    var thumbnail: UIImage? =  nil
    
    init(titleText: String?, urlText: String?, image: UIImage?) {
        title = titleText
        url = urlText
        thumbnail = image
    }
}
