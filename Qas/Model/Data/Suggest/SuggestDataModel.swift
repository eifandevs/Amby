//
//  SuggestDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import Moya

final class SuggestDataModel {

    /// サジェスト通知用RX
    let rx_suggestDataModelDidUpdate = PublishSubject<Suggest>()
    
    static let s = SuggestDataModel()
    private let disposeBag = DisposeBag()

    func fetch(token: String) {
        let provider = ApiProvider<Google>()
        
        provider.rx.request(.suggest(token: token))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> SuggestResponse? in
                return SuggestResponse(data: (try? JSONSerialization.jsonObject(with: response.data)) as! [Any])
            }
            .subscribe(onSuccess: { [weak self] (response) in
                log.eventIn(chain: "rx_suggest")
                
                guard let `self` = self else { return }
                if let unwrappedResponse = response, let suggests = unwrappedResponse.data[safe: 1] {
                    self.rx_suggestDataModelDidUpdate.onNext(Suggest(token: token, data: suggests as? [String]))
                } else {
                    self.rx_suggestDataModelDidUpdate.onNext(Suggest(token: token, data: nil))
                }
                
                log.eventOut(chain: "rx_suggest")
            }, onError: { error in
                log.eventIn(chain: "rx_suggest")
                
                log.error("get suggest error. error: \(error.localizedDescription)")
                self.rx_suggestDataModelDidUpdate.onNext(Suggest(token: token, data: nil))
                
                log.eventOut(chain: "rx_suggest")
            })
            .disposed(by: disposeBag)
    }
}
