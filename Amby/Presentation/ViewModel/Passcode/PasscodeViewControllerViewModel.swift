//
//  PasscodeViewControllerViewModel.swift
//  Amby
//
//  Created by tenma on 2018/10/26.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

enum PasscodeViewControllerViewModelAction {
    case confirm
    case confirmSuccess
    case register
}

enum PasscodeViewControllerViewModelError {
    case confirm
}

final class PasscodeViewControllerViewModel {
    /// アクション通知用RX
    let rx_action = PublishSubject<PasscodeViewControllerViewModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<PasscodeViewControllerViewModelError>()

    var title = Variable(MessageConst.PASSCODE.TITLE_REGISTER)

    /// 新規作成 or 確認
    var isConfirm = false {
        didSet {
            title.value = isConfirm ? MessageConst.PASSCODE.TITLE_INPUT : MessageConst.PASSCODE.TITLE_REGISTER
        }
    }

    /// パスコード登録済みフラグ
    var isRegisterdPasscode: Bool {
        return PasscodeHandlerUseCase.s.isRegisterdPasscode
    }

    /// パスコード入力済みフラグ
    var isInputPasscode: Bool {
        return !inputPasscode.isEmpty
    }

    /// 入力パスコード
    private var inputPasscode = ""

    /// パスコード
    private var passcode: String {
        return PasscodeHandlerUseCase.s.rootPasscode
    }

    /// パスコード入力
    func input(passcode: String) {
        if isConfirm {
            if self.passcode == passcode {
                PasscodeHandlerUseCase.s.isInputPasscode = true
                rx_action.onNext(.confirmSuccess)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.PASSCODE_AUTHENTIFICATED, isSuccess: true)
                }
            } else {
                rx_error.onNext(.confirm)
            }
        } else {
            if inputPasscode.isEmpty {
                inputPasscode = passcode
                title.value = MessageConst.PASSCODE.TITLE_CONFIRM
                rx_action.onNext(.confirm)
            } else {
                if inputPasscode == passcode {
                    rx_action.onNext(.register)
                    PasscodeHandlerUseCase.s.rootPasscode = passcode
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.PASSCODE_REGISTERED, isSuccess: true)
                    }
                } else {
                    inputPasscode = ""
                    title.value = MessageConst.PASSCODE.TITLE_REGISTER
                    rx_error.onNext(.confirm)
                }
            }
        }
    }

    /// アプリ初期化
    func initializeApp() {
        DeleteHistoryUseCase().exe()
        DeleteSearchUseCase().exe()
        DeleteFavoriteUseCase().exe()
        DeleteFormUseCase().exe()
        WebCacheHandlerUseCase.s.deleteCookies()
        WebCacheHandlerUseCase.s.deleteCaches()
        DeleteThumbnailUseCase().exe()
        DeleteTabUseCase().exe()
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.initialize()
        }
    }
}
