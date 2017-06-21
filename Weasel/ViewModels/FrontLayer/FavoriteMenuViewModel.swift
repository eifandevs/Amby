//
//  FormMenuViewModel.swift
//  Weasel
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
        let items = StoreManager.shared.selectAllFavorite().map { (favorite) -> OptionMenuItem in
            return OptionMenuItem(titleText: favorite.title, urlText: favorite.url, image: nil)
        }
        
        menuItems.append(items)
        commonAction = { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
            let encodedText = menuItem.url!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            NotificationCenter.default.post(name: .baseViewModelWillSearchWebView, object: encodedText!)
            return nil
        }
    }
}
