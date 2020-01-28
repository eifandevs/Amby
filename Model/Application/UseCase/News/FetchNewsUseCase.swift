//
//  GetNewsUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/11.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class GetNewsUseCase {

    private var articleDataModel: ArticleDataModelProtocol!
    var fetchNewsDispose: Disposable?
    var fetchNewsErrorDispose: Disposable?

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        articleDataModel = ArticleDataModel.s
    }

    public func exe() -> Observable<[GetArticleResponse.Article]?> {
        return Observable.create { [weak self] observable in
            guard let `self` = self else {
                observable.onError(NSError.empty)
                return Disposables.create()
            }

            log.debug("fetch news start...")

            self.fetchNewsDispose = self.articleDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case let .update(articles):
                        log.debug("fetch news success")
                        observable.onNext(articles)
                        observable.onCompleted()
                        self.fetchNewsDispose!.dispose()
                    default: break
                    }
                }

            self.fetchNewsErrorDispose = self.articleDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .fetch:
                        log.error("fetch news error")
                        observable.onError(NSError.empty)
                        self.fetchNewsErrorDispose!.dispose()
                    default: break
                    }
                }

            self.articleDataModel.fetch(request: GetArticleRequest())

            return Disposables.create()
       }
    }
}
