//
//  CircleMenuViewModel.swift
//  Qass
//
//  Created by tenma on 2018/07/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class CircleMenuViewModel {
    let menuItems: [[UserOperation]] = [
        [.menu, .close, .historyBack, .copy, .search, .add],
        [.scrollUp, .autoScroll, .historyForward, .form, .favorite, .grep]
    ]
    var menuIndex = 0
}
