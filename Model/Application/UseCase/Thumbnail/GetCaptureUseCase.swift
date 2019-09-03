//
//  GetCaptureUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class GetCaptureUseCase {

    private var thumbnailDataModel: ThumbnailDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        thumbnailDataModel = ThumbnailDataModel.s
    }

    public func exe(context: String) -> UIImage? {
        return thumbnailDataModel.getCapture(context: context)
    }
}
