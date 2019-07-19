//
//  GoogleSignInService.swift
//  Amby
//
//  Created by iori tenma on 2019/07/19.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import GoogleSignIn

class GoogleSignInService {
    class func setup() {
        GIDSignIn.sharedInstance().clientID = ""
    }
}
