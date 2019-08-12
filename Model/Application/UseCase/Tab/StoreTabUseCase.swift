//
//  AddGroupUsecase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class StoreTabUseCase {

    private var tabDataModel: TabDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
    }

    /// 閲覧、ページ履歴の永続化
    public func exe() {
        DispatchQueue(label: ModelConst.APP.QUEUE).async {
            self.tabDataModel.store()
        }
    }
}
