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
    case get(accessToken: AccessToken?)
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
    var AccessTokens: [AccessToken] { get }
    func get()
}

final class AccessTokenDataModel: AccessTokenDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<AccessTokenDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<AccessTokenDataModelError>()
    
    /// 記事
    public private(set) var AccessTokens = [AccessToken]()
    
    static let s = AccessTokenDataModel()
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    /// 記事取得
    func get() {
        let repository = ApiRepository<App>()
        
        repository.rx.request(.accessToken)
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
                        self.rx_action.onNext(.get(accessToken: response.data))
                    } else {
                        log.error("get AccessToken error. code: \(response.code)")
                        self.rx_error.onNext(.get)
                        self.rx_action.onNext(.get(accessToken: nil))
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("get AccessToken error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.get)
                    self.rx_action.onNext(.get(accessToken: nil))
            })
            .disposed(by: disposeBag)
    }
}
