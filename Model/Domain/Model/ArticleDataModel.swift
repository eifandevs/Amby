//
//  ArticleDataModel.swift
//  Amby
//
//  Created by temma on 2018/02/18.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Moya
import RxCocoa
import RxSwift

enum ArticleDataModelAction {
    case update(articles: [GetArticleResponse.Article])
}

enum ArticleDataModelError {
    case fetch
}

extension ArticleDataModelError: ModelError {
    var message: String {
        switch self {
        case .fetch:
            return MessageConst.NOTIFICATION.GET_ARTICLE_ERROR
        }
    }
}

protocol ArticleDataModelProtocol {
    var rx_action: PublishSubject<ArticleDataModelAction> { get }
    var rx_error: PublishSubject<ArticleDataModelError> { get }
    var articles: [GetArticleResponse.Article] { get }
    func fetch()
}

final class ArticleDataModel: ArticleDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<ArticleDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<ArticleDataModelError>()

    /// 記事
    public private(set) var articles = [GetArticleResponse.Article]()

    static let s = ArticleDataModel()
    private let disposeBag = DisposeBag()

    private init() {}

    /// 記事取得
    func fetch() {
        if articles.count == 0 {
            let repository = ApiRepository<App>()

            repository.rx.request(.article)
                .observeOn(MainScheduler.asyncInstance)
                .map { (response) -> GetArticleResponse in

                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        let articleResponse: GetArticleResponse = try decoder.decode(GetArticleResponse.self, from: response.data)
                        return articleResponse
                    } catch {
                        return GetArticleResponse(code: ModelConst.APP_STATUS_CODE.PARSE_ERROR, data: [])
                    }
                }
                .subscribe(
                    onSuccess: { [weak self] response in
                        guard let `self` = self else { return }
                        if response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                            log.debug("get article success.")
                            self.articles = response.data
                            self.rx_action.onNext(.update(articles: response.data))
                        } else {
                            log.error("get article error. code: \(response.code)")
                            self.rx_error.onNext(.fetch)
                            self.rx_action.onNext(.update(articles: []))
                        }
                    }, onError: { [weak self] error in
                        guard let `self` = self else { return }
                        log.error("get article error. error: \(error.localizedDescription)")
                        self.rx_error.onNext(.fetch)
                        self.rx_action.onNext(.update(articles: []))
                })
                .disposed(by: disposeBag)
        } else {
            // 取得済みルート
            rx_action.onNext(.update(articles: articles))
        }
    }
}
