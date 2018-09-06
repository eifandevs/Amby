//
//  ArticleDataModel.swift
//  Qas
//
//  Created by temma on 2018/02/18.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation
import Model
import Moya
import RxCocoa
import RxSwift

final class ArticleDataModel {
    /// 記事取得通知用RX
    let rx_articleDataModelDidUpdate = PublishSubject<[Article]>()

    /// 記事
    public private(set) var articles = [Article]()

    static let s = ArticleDataModel()
    private let disposeBag = DisposeBag()

    private init() {}

    /// 記事取得
    func get() {
        /// TODO: 前回の取得から3時間経過していたら取得する
        if articles.count == 0 {
            let repository = ApiRepository<App>()

            repository.rx.request(.article)
                .observeOn(MainScheduler.asyncInstance)
                .map { (response) -> ArticleResponse in

                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        let articleResponse: ArticleResponse = try decoder.decode(ArticleResponse.self, from: response.data)
                        return articleResponse
                    } catch {
                        return ArticleResponse(code: AppHttpConst.APP_STATUS_CODE.PARSE_ERROR, data: [])
                    }
                }
                .subscribe(
                    onSuccess: { [weak self] response in
                        log.eventIn(chain: "rx_article")

                        guard let `self` = self else { return }
                        if response.code == AppHttpConst.APP_STATUS_CODE.NORMAL {
                            log.debug("get article success.")
                            self.articles = response.data
                            self.rx_articleDataModelDidUpdate.onNext(response.data)
                        } else {
                            log.error("get article error. code: \(response.code)")
                            self.rx_articleDataModelDidUpdate.onNext([])
                        }

                        log.eventOut(chain: "rx_article")
                    }, onError: { error in
                        log.eventIn(chain: "rx_article")

                        log.error("get article error. error: \(error.localizedDescription)")
                        self.rx_articleDataModelDidUpdate.onNext([])

                        log.eventOut(chain: "rx_article")
                })
                .disposed(by: disposeBag)
        } else {
            // 取得済みルート
            rx_articleDataModelDidUpdate.onNext(articles)
        }
    }
}
