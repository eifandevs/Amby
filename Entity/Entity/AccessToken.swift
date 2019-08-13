//
//  AccessToken.swift
//  Entity
//
//  Created by iori tenma on 2019/08/13.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
public struct AccessToken: Codable {
    public var accessToken: String?
    public var refreshToken: String?
}
