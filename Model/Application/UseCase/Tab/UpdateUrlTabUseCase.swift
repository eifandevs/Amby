//
//  AddGroupUsecase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class UpdateUrlTabUseCase {

    private var tabDataModel: TabDataModelProtocol!
    private var progressDataModel: ProgressDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!

    public var currentTab: Tab? {
        return tabDataModel.currentTab
    }

    public var currentContext: String {
        return tabDataModel.currentContext
    }

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        progressDataModel = ProgressDataModel.s
        tabDataModel = TabDataModel.s
        favoriteDataModel = FavoriteDataModel.s
    }

    /// update url in page history
    public func exe(context: String, url: String) {
        if !url.isEmpty && url.isValidUrl {
            tabDataModel.updateUrl(context: context, url: url)
            if let currentTab = currentTab, context == currentContext {
                progressDataModel.updateText(text: url)
                favoriteDataModel.reload(currentTab: currentTab)
            }
        }
    }
}
