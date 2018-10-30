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

final class PasscodeViewControllerViewModel {
    /// 確認コード入力要求通知用RX
    let rx_passcodeViewControllerViewModelWillConfirm = PublishSubject<()>()
    /// 確認コード入力失敗通知用RX
    let rx_passcodeViewControllerViewModelDidConfirmError = PublishSubject<()>()
    /// 確認コード入力成功通知用RX
    let rx_passcodeViewControllerViewModelDidConfirmSuccess = PublishSubject<()>()
    /// パスコード登録成功通知用RX
    let rx_passcodeViewControllerViewModelDidRegister = PublishSubject<()>()

    var title = Variable(MessageConst.PASSCODE.TITLE_REGISTER)

    /// 新規作成 or 確認
    var isConfirm = false {
        didSet {
            title.value = isConfirm ? MessageConst.PASSCODE.TITLE_INPUT : MessageConst.PASSCODE.TITLE_REGISTER
        }
    }

    /// パスコード登録済みフラグ
    var isRegisterdPasscode: Bool {
        return !passcode.isEmpty
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
                rx_passcodeViewControllerViewModelDidConfirmSuccess.onNext(())
            } else {
                rx_passcodeViewControllerViewModelDidConfirmError.onNext(())
            }
        } else {
            if inputPasscode.isEmpty {
                inputPasscode = passcode
                title.value = MessageConst.PASSCODE.TITLE_CONFIRM
                rx_passcodeViewControllerViewModelWillConfirm.onNext(())
            } else {
                if inputPasscode == passcode {
                    rx_passcodeViewControllerViewModelDidRegister.onNext(())
                    PasscodeUseCase.s.rootPasscode = passcode
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationManager.presentToastNotification(message: MessageConst.NOTIFICATION.PASSCODE_REGISTERED, isSuccess: true)
                    }
                } else {
                    inputPasscode = ""
                    title.value = MessageConst.PASSCODE.TITLE_REGISTER
                    rx_passcodeViewControllerViewModelDidConfirmError.onNext(())
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
