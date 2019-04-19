//
//  JSON+Extend.swift
//  CommonUtil
//
//  Created by iori tenma on 2019/04/11.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension JSON {
    func toString() -> String? {
        return self.rawString(.utf8, options: [])
    }
}
