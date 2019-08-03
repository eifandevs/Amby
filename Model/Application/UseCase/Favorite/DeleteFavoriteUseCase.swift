//
//  DeleteFavoriteUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class DeleteFavoriteUseCase {

    private var favoriteDataModel: FavoriteDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        favoriteDataModel = FavoriteDataModel.s
    }

    public func exe() {
        favoriteDataModel.delete()
    }

    public func exe(favorites: [Favorite]) {
        favoriteDataModel.delete(favorites: favorites)
    }
}
