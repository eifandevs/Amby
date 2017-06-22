//
//  FormMenuViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/21.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class FormMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
    }
    
    override func setup() {
        let items = StoreManager.shared.selectAllForm().map { (form) -> OptionMenuItem in
            return OptionMenuItem(title: form.title, url: form.url, image: nil)
        }
        
        menuItems.append(items)
        commonAction = { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
            let encodedText = menuItem.url!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            NotificationCenter.default.post(name: .baseViewModelWillSearchWebView, object: encodedText!)
            return nil
        }
    }
}
