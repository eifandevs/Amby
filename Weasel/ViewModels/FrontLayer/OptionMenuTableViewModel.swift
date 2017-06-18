//
//  OptionMenuTableViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/13.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class OptionMenuTableViewModel {
    var sectionItems: [String] = []
    var menuItems: [[String]] = []
    var actionItems: [(() -> (OptionMenuTableViewModel?))] = []
    init() {
    }
    func setup() {
    
    }
}
