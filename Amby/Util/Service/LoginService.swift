//
//  LoginService.swift
//  Amby
//
//  Created by tenma.i on 2019/10/16.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Firebase
import Foundation
import GoogleSignIn

class LoginService {
    
    var isLoginedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    func signOut() {
        GIDSignIn.sharedInstance()!.signOut()
        try! Auth.auth().signOut()
        log.debug("logout")
    }

    func deleteAccount() {
        Auth.auth().currentUser?.delete(completion: { error in
            if let error = error {
                log.error("delete account faild. error: \(error)")
                return
            }
            log.debug("delete account success.")
        })
    }
}
