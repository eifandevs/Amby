//
//  Array+Extend.swift
//  Qas
//
//  Created by temma on 2017/08/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

// 配列の重複を削除
extension Array where Element: Equatable {
    /// オブジェクト指定で削除
    mutating func remove<T : Equatable>(obj : T) -> Array {
        self = self.filter({$0 as? T != obj})
        return self
    }
    
    /// 複数のオブジェクトを安全にとりだす
    func objects(for : Int) -> Array {
        if self.count == 0 {
            return self
        }
        guard 0...self.count-1 ~= `for` else {
            return objects(for: self.count - 1)
        }
        return Array(self[0...`for`])
    }
}
