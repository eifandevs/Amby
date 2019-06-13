//
//  HeaderFieldViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/16.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class HeaderFieldViewModel {
    /// サジェストリクエスト
    func suggest(word: String) {
        SuggestUseCase.s.suggest(word: word)
    }
}
