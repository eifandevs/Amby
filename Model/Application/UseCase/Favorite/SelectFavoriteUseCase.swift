//
//  SelectFavoriteUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class SelectFavoriteUseCase {

    private var favoriteDataModel: FavoriteDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        favoriteDataModel = FavoriteDataModel.s
    }

    public func exe() -> [Favorite] {
        return favoriteDataModel.select()
    }

    public func exe(id: String) -> [Favorite] {
        return favoriteDataModel.select(id: id)
    }

    public func exe(url: String) -> [Favorite] {
        return favoriteDataModel.select(url: url)
    }
}
