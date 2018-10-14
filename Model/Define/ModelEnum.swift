//
//  ModelEnum.swift
//  Model
//
//  Created by tenma on 2018/10/15.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

/// アプリ内Enumクラス

// MARK: - オペレーション

public enum UserOperation: Int {
    case menu = 1
    case add
    case close
    case copy
    case autoScroll
    case grep
    case form
    case favorite
    case autoFill
    case urlCopy
    case search
    case scrollUp
    case suggest
    case historyBack
    case historyForward
}
