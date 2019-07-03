//
//  FirebaseUseCase.swift
//  Model
//
//  Created by tenma on 2019/07/03.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Firebase

public final class FirebaseUseCase {
    public static let s = FirebaseUseCase()
    
    public func setup() {
        guard let fileopts = FirebaseOptions(contentsOfFile: ResourceUtil().firebaseConfigPath)
            else { assert(false, "Couldn't load config file") }
        FirebaseApp.configure(options: fileopts)
    }
}
