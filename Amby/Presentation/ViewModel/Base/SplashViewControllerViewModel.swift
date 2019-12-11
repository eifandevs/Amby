//
//  SplashViewControllerViewModel.swift
//  Amby
//
//  Created by tenma.i on 2019/10/25.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model
import RxCocoa
import RxSwift

final class SplashViewControllerViewModel {
    let getAccessTokenUC = GetAccessTokenUseCase()

    func getAccessToken() -> Single<()> {
        return getAccessTokenUC.exe()
    }
}
