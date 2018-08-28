//
//  CollectionType+Extend.swift
//  Qass
//
//  Created by tenma on 2018/04/12.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    func find(_ isIncluded: (Array.Iterator.Element) -> Bool) -> Array.Iterator.Element? {
        return filter(isIncluded).first
    }
}
