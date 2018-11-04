//
//  PasscodeUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/21.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// パスコードユースケース
public final class PasscodeUseCase {
    public static let s = PasscodeUseCase()

    /// オープンリクエスト通知用RX
    public let rx_passcodeUseCaseDidRequestOpen = PublishSubject<()>()

    /// オープンリクエスト通知用RX
    public let rx_passcodeUseCaseDidRequestConfirm = PublishSubject<()>()

    /// パスコード
    public var rootPasscode: String {
        get {
            return SettingDataModel.s.rootPasscode
        }
        set(value) {
            SettingDataModel.s.rootPasscode = value
        }
    }

    /// パスコート認証済みフラグ
    public var isInputPasscode: Bool {
        get {
            return AuthDataModel.s.isInputPasscode
        }
        set(value) {
            AuthDataModel.s.isInputPasscode = value
        }
    }

    /// パスコード登録済みフラグ
    public var isRegisterdPasscode: Bool {
        return !rootPasscode.isEmpty
    }

    private init() {}

    /// ライセンス表示
    public func open() {
        rx_passcodeUseCaseDidRequestOpen.onNext(())
    }

    /// 確認画面表示
    public func confirm() {
        rx_passcodeUseCaseDidRequestConfirm.onNext(())
    }
}
