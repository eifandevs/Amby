//
//  FormMenuViewModel.swift
//  Qas
//
//  Created by User on 2017/06/21.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class FavoriteMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
    }
    
    override func setup() {
        let items = FavoriteDataModel.s.select().map { (favorite) -> OptionMenuItem in
            return OptionMenuItem(_id: favorite.id, type: .deletablePlain, title: favorite.title, url: favorite.url)
        }
        
        menuItems.append(items)
        commonAction = { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
            let encodedText = menuItem.url!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            NotificationCenter.default.post(name: .baseViewModelWillSearchWebView, object: encodedText!)
            return nil
        }
    }
}
