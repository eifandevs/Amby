//
//  Model.swift
//  Model
//
//  Created by tenma on 2018/08/30.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Firebase

let log = ModelLogger.self

public final class Model {
    public static func setup() {
        #if DEBUG
            log.info("DEBUG BUILD")
        #endif

        #if UT
            log.info("UT BUILD")
        #endif

        #if LOCAL
            log.info("LOCAL BUILD")
        #endif

        #if RELEASE
            log.info("RELEASE BUILD")
            guard let fileopts = FirebaseOptions(contentsOfFile: ResourceUtil().firebaseConfigPath)
                else { assert(false, "Couldn't load config file") }
            FirebaseApp.configure(options: fileopts)
        #endif

        // ローカルストレージセットアップ
        let repository = LocalStorageRepository<Cache>()
        _ = repository.create(.commonHistory(resource: nil))
        _ = repository.create(.database(resource: nil))
        _ = repository.create(.searchHistory(resource: nil))
        _ = repository.create(.thumbnails(additionalPath: nil, resource: nil))
    }
}
