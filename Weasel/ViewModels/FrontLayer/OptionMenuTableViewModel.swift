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
    var menuItems: [[OptionMenuItem]] = []
    var actionItems: [[((OptionMenuItem) -> (OptionMenuTableViewModel?))]] = []
    var commonAction: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil
    init() {
    }
    func setup() { /* setupコール時に上記Itemsに値を入れる */ }
}
