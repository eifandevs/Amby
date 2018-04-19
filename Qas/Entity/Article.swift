//
//  Article.swift
//  Qas
//
//  Created by tenma on 2018/04/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

struct Article: Codable {
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
}
