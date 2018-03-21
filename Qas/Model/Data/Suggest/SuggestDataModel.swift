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

    static let s = SuggestDataModel()
    private let disposeBag = DisposeBag()

    static func fetch(token: String, completion: ((Suggest?) -> ())?) {
        let api = ApiClient(url: HttpConst.SUGGEST_SERVER_DOMAIN + HttpConst.SUGGEST_SERVER_PATH + token)
        api.get(success: { (json: Dictionary) in
            let data = (json["result"] as? [Any] ?? [String]())[safe: 1] as? [String] ?? [String]()
            completion?(Suggest(data: data))
        }) { (error: Error?) in
            completion?(nil)
        }
    }
    
    func fetch(token: String) {
        let suggestProvider = ApiProvider<Common>()
        suggestProvider.rx.request(.suggest(token: "aaa"))
            .map { (response) -> SuggestResponse? in
                return try? JSONDecoder().decode(SuggestResponse.self, from: response.data)
            }
            .subscribe(onSuccess: { (response) in
                if let unwrappedResponse = response {
                    print(unwrappedResponse)
                } else {
                    print("error")
                }
            }, onError: { (error) in
                print("error")
            })
            .disposed(by: disposeBag)
    }
}
