//
//  PasscodeViewControllerViewModel.swift
//  Qass
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
        return PasscodeUseCase.s.isRegisterdPasscode
    }

    /// パスコード入力済みフラグ
    var isInputPasscode: Bool {
        return !inputPasscode.isEmpty
    }

    /// 入力パスコード
    private var inputPasscode = ""

    /// パスコード
    private var passcode: String {
        return PasscodeUseCase.s.rootPasscode
    }

    /// パスコード入力
    func input(passcode: String) {
        if isConfirm {
            if self.passcode == passcode {
                PasscodeUseCase.s.isInputPasscode = true
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
                    PasscodeUseCase.s.rootPasscode = passcode
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
        HistoryUseCase.s.delete()
        SearchUseCase.s.delete()
        FavoriteUseCase.s.delete()
        FormUseCase.s.delete()
        WebCacheUseCase.s.deleteCookies()
        WebCacheUseCase.s.deleteCaches()
        ThumbnailUseCase.s.delete()
        TabUseCase.s.delete()
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.initialize()
        }
    }
}
