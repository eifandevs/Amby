//
//  DeleteThumbnailUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class DeleteThumbnailUseCase {

    private var thumbnailDataModel: ThumbnailDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        thumbnailDataModel = ThumbnailDataModel.s
    }

    public func exe() {
        thumbnailDataModel.delete()
    }

    /// サムネイルの削除
    public func exe(context: String) {
        thumbnailDataModel.delete(context: context)
    }
}
