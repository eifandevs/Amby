//
//  SuggestDataModel.swift
//  Amby
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Alamofire
import CommonUtil
import Entity
import Foundation
import Moya
import RxCocoa
import RxSwift

enum SuggestDataModelAction {
    case update(suggest: Suggest)
}

enum SuggestDataModelError {
    case update
}

extension SuggestDataModelError: ModelError {
    var message: String {
        switch self {
        case .update:
            return MessageConst.NOTIFICATION.GET_SUGGEST_ERROR
        }
    }
}

protocol SuggestDataModelProtocol {
    var rx_action: PublishSubject<SuggestDataModelAction> { get }
    func get(token: String)
}

final class SuggestDataModel: SuggestDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<SuggestDataModelAction>()

    static let s = SuggestDataModel()
    private let disposeBag = DisposeBag()

    private init() {}

    func get(token: String) {
        let repository = ApiRepository<Google>()

        repository.rx.request(.suggest(token: token))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> GetSuggestResponse? in
                return GetSuggestResponse(data: (try? JSONSerialization.jsonObject(with: response.data)) as? [Any] ?? [])
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    log.debug("get suggest success.")
                    if let unwrappedResponse = response, let suggests = unwrappedResponse.data[safe: 1] {
                        self.rx_action.onNext(.update(suggest: Suggest(token: token, data: suggests as? [String])))
                    } else {
                        self.rx_action.onNext(.update(suggest: Suggest(token: token, data: nil)))
                    }
                }, onError: { error in
                    log.error("get suggest error. error: \(error.localizedDescription)")
                    self.rx_action.onNext(.update(suggest: Suggest(token: token, data: nil)))
            })
            .disposed(by: disposeBag)
    }
}
