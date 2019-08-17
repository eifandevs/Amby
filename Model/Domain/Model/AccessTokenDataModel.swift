//
//  AccessTokenDataModel.swift
//  Model
//
//  Created by iori tenma on 2019/08/01.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Moya
import RxCocoa
import RxSwift

enum AccessTokenDataModelAction {
    case get(accessToken: AccessToken)
}

enum AccessTokenDataModelError {
    case get
}

extension AccessTokenDataModelError: ModelError {
    var message: String {
        switch self {
        case .get:
            return MessageConst.NOTIFICATION.COMMON_ERROR
        }
    }
}

protocol AccessTokenDataModelProtocol {
    var rx_action: PublishSubject<AccessTokenDataModelAction> { get }
    var rx_error: PublishSubject<AccessTokenDataModelError> { get }
    var realmEncryptionToken: String! { get }
    var keychainServiceToken: String! { get }
    var keychainIvToken: String! { get }
    func get(request: AccessTokenRequest)
}

final class AccessTokenDataModel: AccessTokenDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<AccessTokenDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<AccessTokenDataModelError>()

    /// DBトークン
    let realmEncryptionToken: String!
    /// キーチェーントークン
    let keychainServiceToken: String!
    /// キーチェーンIVトークン
    let keychainIvToken: String!

    static let s = AccessTokenDataModel()
    private let disposeBag = DisposeBag()

    private init() {
        let repository = KeychainRepository()

        if let realmEncryptionToken = repository.get(key: ModelConst.KEY.REALM_TOKEN) {
            self.realmEncryptionToken = realmEncryptionToken
        } else {
            realmEncryptionToken = String.getRandomStringWithLength(length: 64)
            repository.save(key: ModelConst.KEY.REALM_TOKEN, value: realmEncryptionToken)
        }

        if let keychainServiceToken = repository.get(key: ModelConst.KEY.ENCRYPT_SERVICE_TOKEN) {
            self.keychainServiceToken = keychainServiceToken
        } else {
            keychainServiceToken = String.getRandomStringWithLength(length: 32)
            repository.save(key: ModelConst.KEY.ENCRYPT_SERVICE_TOKEN, value: keychainServiceToken)
        }

        if let keychainIvToken = repository.get(key: ModelConst.KEY.ENCRYPT_IV_TOKEN) {
            self.keychainIvToken = keychainIvToken
        } else {
            keychainIvToken = String.getRandomStringWithLength(length: 16)
            repository.save(key: ModelConst.KEY.ENCRYPT_IV_TOKEN, value: keychainIvToken)
        }
    }

    /// 記事取得
    func get(request: AccessTokenRequest) {
        let repository = ApiRepository<App>()

        repository.rx.request(.accessToken(request: request))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> AccessTokenResponse in

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let accessTokenResponse: AccessTokenResponse = try decoder.decode(AccessTokenResponse.self, from: response.data)
                    return accessTokenResponse
                } catch {
                    return AccessTokenResponse(code: ModelConst.APP_STATUS_CODE.PARSE_ERROR, data: nil)
                }
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    if response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                        log.debug("get AccessToken success.")
                        self.rx_action.onNext(.get(accessToken: response.data!))
                    } else {
                        log.error("get AccessToken error. code: \(response.code)")
                        self.rx_error.onNext(.get)
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("get AccessToken error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.get)
            })
            .disposed(by: disposeBag)
    }
}
