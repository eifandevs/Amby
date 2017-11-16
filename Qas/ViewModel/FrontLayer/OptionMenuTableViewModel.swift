//
//  OptionMenuTableViewModel.swift
//  Qas
//
//  Created by User on 2017/06/13.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class OptionMenuTableViewModel {
    var sectionItems: [String] = []
    var menuItems: [[OptionMenuItem]] = []
    var commonAction: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = nil
    let optionMenuMargin = AppConst.FRONT_LAYER_OPTION_MENU_MARGIN
    init() {
    }
    func setup() { /* setupコール時に上記Itemsに値を入れる */ }
    
    /// セクションの削除
    func deleteSection(index: NSInteger) {
        sectionItems.remove(at: index)
        menuItems.remove(at: index)
    }
}
