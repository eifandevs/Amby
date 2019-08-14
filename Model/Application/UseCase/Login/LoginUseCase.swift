//
//  LoginUseCase.swift
//  Amby
//
//  Created by tenma.i on 2019/08/14.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class LoginUseCase {
    
    private var accessTokenDataModel: AccessTokenDataModelProtocol!
    
    public init() {
        setupProtocolImpl()
    }
    
    private func setupProtocolImpl() {
        accessTokenDataModel = AccessTokenDataModel.s
    }
    
    public func exe() {
        accessTokenDataModel.get()
    }
}
