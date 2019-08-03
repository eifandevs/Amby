//
//  UpdateFavoriteUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class UpdateFavoriteUseCase {

    private var tabDataModel: TabDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        favoriteDataModel = FavoriteDataModel.s
    }

    /// お気に入り更新
    public func exe() {
        if let currentTab = tabDataModel.currentTab {
            favoriteDataModel.update(currentTab: currentTab)
        }
    }
}
