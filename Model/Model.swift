//
//  Model.swift
//  Model
//
//  Created by tenma on 2018/08/30.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

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
        #endif

        // 設定データ(UD)セットアップ
        SettingDataModel.s.setup()

        // ローカルストレージセットアップ
        let repository = LocalStorageRepository<Cache>()
        repository.create(.commonHistory(resource: nil))
        repository.create(.database(resource: nil))
        repository.create(.searchHistory(resource: nil))
        repository.create(.thumbnails(additionalPath: nil, resource: nil))
    }
}
