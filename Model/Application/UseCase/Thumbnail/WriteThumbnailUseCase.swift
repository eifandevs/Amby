//
//  WriteThumbnailUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class WriteThumbnailUseCase {

    private var thumbnailDataModel: ThumbnailDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        thumbnailDataModel = ThumbnailDataModel.s
    }

    /// write thumbnail data
    public func exe(context: String, data: Data) {
        thumbnailDataModel.write(context: context, data: data)
    }
}
