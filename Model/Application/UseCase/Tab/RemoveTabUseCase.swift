//
//  RemoveTabUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class RemoveTabUseCase {

    private var tabDataModel: TabDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
    }

    /// 現在のタブを削除
    public func exe() {
        tabDataModel.remove(context: tabDataModel.currentContext)
    }

    /// 特定のタブを削除
    public func exe(context: String) {
        tabDataModel.remove(context: context)
    }
}
