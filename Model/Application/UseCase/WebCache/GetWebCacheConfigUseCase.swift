//
//  GetWebCacheConfigUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift
import WebKit

public final class GetWebCacheConfigUseCase {

    private var tabDataModel: TabDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
    }

    public func exe() -> WKWebViewConfiguration {
        let dataStore = tabDataModel.isPrivate ? WKWebsiteDataStore.nonPersistent() : WKWebsiteDataStore.default()
        log.debug("set data store mode: \(dataStore.isPersistent ? "persistent" : "nonpersistent")")
        return CacheService.cacheConfiguration(dataStore: dataStore)
    }
}
