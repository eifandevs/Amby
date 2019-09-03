//
//  CreateThumbnailFolderUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class CreateThumbnailFolderUseCase {

    private var thumbnailDataModel: ThumbnailDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        thumbnailDataModel = ThumbnailDataModel.s
    }

    /// create thumbnail folder
    public func exe(context: String) {
        thumbnailDataModel.create(context: context)
    }
}
