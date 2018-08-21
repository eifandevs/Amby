//
//  Article.swift
//  Qas
//
//  Created by tenma on 2018/04/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

struct Article: Codable {
    var id: Int?
    var source_name: String?
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var image_url: String?
    var published_time: String?
    var created_at: String?
    var updated_at: String?
    var next_update: String?
}
