//
//  UserDataModel.swift
//  Model
//
//  Created by tenma.i on 2019/10/31.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Moya
import RxCocoa
import RxSwift

enum UserDataModelAction {
    case post(userInfo: LoginResponse.UserInfo)
}

enum UserDataModelError {
    case post
}

extension UserDataModelError: ModelError {
    var message: String {
        switch self {
        case .post:
            return MessageConst.NOTIFICATION.COMMON_ERROR
        }
    }
}

protocol UserDataModelProtocol {
    var rx_action: PublishSubject<UserDataModelAction> { get }
    var rx_error: PublishSubject<UserDataModelError> { get }
    var uid: String? { get }
    var hasUID: Bool { get }
    func post(request: LoginRequest)
}

final class UserDataModel: UserDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<UserDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<UserDataModelError>()

    /// uid
    var uid: String?

    var hasUID: Bool {
        return uid != nil
    }

    static let s = UserDataModel()
    private let disposeBag = DisposeBag()

    private init() {
        let repository = KeychainRepository()

        if let uid = repository.get(key: ModelConst.KEY.KEYCHAIN_KEY_USER_ID) {
            self.uid = uid
        }
    }

    /// Get API access token
    func post(request: LoginRequest) {
        let repository = ApiRepository<App>()

        repository.rx.request(.login(request: request))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> LoginResponse? in
                log.debug("response: \(String(data: response.data, encoding: .utf8))")
                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let loginResponse: LoginResponse = try decoder.decode(LoginResponse.self, from: response.data)
                    return loginResponse
                } catch let error as NSError {
                    log.error("parse error. error: \(error)")
                    return nil
                }
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    if let response = response, response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                        log.debug("login success.")
                        self.uid = response.data.userId
                        KeychainRepository().save(key: ModelConst.KEY.KEYCHAIN_KEY_USER_ID, value: response.data.userId)
                        self.rx_action.onNext(.post(userInfo: response.data))
                    } else {
                        log.error("login error. code: \(response?.code ?? "")")
                        self.rx_error.onNext(.post)
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("login error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.post)
            })
            .disposed(by: disposeBag)
    }

    func delete() {}
}
