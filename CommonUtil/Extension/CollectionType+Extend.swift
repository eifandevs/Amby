//
//  CollectionType+Extend.swift
//  Amby
//
//  Created by tenma on 2018/04/12.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

public extension Array {
    public func find(_ isIncluded: (Array.Iterator.Element) -> Bool) -> Array.Iterator.Element? {
        return filter(isIncluded).first
    }
}
