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
    case fetch(accessToken: GetAccessTokenResponse.AccessToken)
}

enum AccessTokenDataModelError {
    case fetch
}

extension AccessTokenDataModelError: ModelError {
    var message: String {
        switch self {
        case .fetch:
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
    var hasApiToken: Bool { get }
    func fetch(request: GetAccessTokenRequest)
}

final class AccessTokenDataModel: AccessTokenDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<AccessTokenDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<AccessTokenDataModelError>()

    /// APIトークン
    var apiToken: String?
    /// DBトークン
    let realmEncryptionToken: String!
    /// キーチェーントークン
    let keychainServiceToken: String!
    /// キーチェーンIVトークン
    let keychainIvToken: String!

    var hasApiToken: Bool {
        return apiToken != nil
    }

    static let s = AccessTokenDataModel()
    private let disposeBag = DisposeBag()

    private init() {
        let repository = KeychainRepository()

        if let apiToken = repository.get(key: ModelConst.KEY.API_TOKEN) {
            self.apiToken = apiToken
        }
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

    /// Get API access token
    func fetch(request: GetAccessTokenRequest) {
        let repository = ApiRepository<App>()

        repository.rx.request(.accessToken(request: request))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> GetAccessTokenResponse? in

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let accessTokenResponse: GetAccessTokenResponse = try decoder.decode(GetAccessTokenResponse.self, from: response.data)
                    return accessTokenResponse
                } catch {
                    return nil
                }
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    if let response = response, response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                        log.debug("get AccessToken success.")
                        self.rx_action.onNext(.fetch(accessToken: response.data))
                    } else {
                        log.error("get AccessToken error. code: \(response?.code ?? "")")
                        self.rx_error.onNext(.fetch)
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("get AccessToken error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.fetch)
            })
            .disposed(by: disposeBag)
    }
}
