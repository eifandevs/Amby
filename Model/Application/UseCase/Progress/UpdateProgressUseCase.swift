//
//  UpdateProgressUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class UpdateProgressUseCase {

    private var progressDataModel: ProgressDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        progressDataModel = ProgressDataModel.s
    }

    public func exe(progress: CGFloat) {
        progressDataModel.updateProgress(progress: progress)
    }
}
