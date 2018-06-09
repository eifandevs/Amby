//
//  ArticleDataModel.swift
//  Qas
//
//  Created by temma on 2018/02/18.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation
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

    /// 記事取得
    func fetch() {
        /// TODO: 記事の取得が必要かをチェック
        if articles.count == 0 {
            let provider = ApiProvider<App>()

            provider.rx.request(.article)
                .observeOn(MainScheduler.asyncInstance)
                .map { (response) -> ArticleResponse in

                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        let articleResponse: ArticleResponse = try decoder.decode(ArticleResponse.self, from: response.data)
                        return articleResponse
                    } catch {
                        return ArticleResponse(code: HttpConst.APP_STATUS_CODE.PARSE_ERROR.rawValue, data: [])
                    }
                }
                .subscribe(
                    onSuccess: { [weak self] response in
                        log.eventIn(chain: "rx_article")

                        guard let `self` = self else { return }
                        if response.code == HttpConst.APP_STATUS_CODE.NORMAL.rawValue {
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
