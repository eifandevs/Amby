//
//  ChangeGroupTitleUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class ChangeGroupTitleUseCase {

    private var tabDataModel: TabDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
    }

    /// グループのタイトル変更
    public func exe(groupContext: String, title: String) {
        tabDataModel.changeGroupTitle(groupContext: groupContext, title: title)
    }
}
