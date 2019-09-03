//
//  FetchFavoriteUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/24.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class FetchFavoriteUseCase {

    private var favoriteDataModel: FavoriteDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        favoriteDataModel = FavoriteDataModel.s
    }

    public func exe() {
        favoriteDataModel.fetch()
    }
}
