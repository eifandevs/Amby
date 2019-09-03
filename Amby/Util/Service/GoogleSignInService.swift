//
//  GoogleSignInService.swift
//  Amby
//
//  Created by iori tenma on 2019/07/19.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Firebase
import Foundation
import GoogleSignIn

class GoogleSignInService {
    class func clientID() -> String {
        guard let fileopts = FirebaseOptions(contentsOfFile: ResourceUtil().googleServiceInfo)
        else { return "" }
        return fileopts.clientID!
    }
}
