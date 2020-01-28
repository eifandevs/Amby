//
//  FavoriteDataModel.swift
//  Amby
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

enum FavoriteDataModelAction {
    case insert(favorites: [Favorite])
    case delete
    case deleteAll
    case reload(url: String)
    case fetch(favorites: [Favorite])
    case post
}

enum FavoriteDataModelError {
    case fetch
    case get
    case store
    case delete
    case post
}

extension FavoriteDataModelError: ModelError {
    var message: String {
        switch self {
        case .fetch:
            return MessageConst.NOTIFICATION.GET_FAVORITE_ERROR
        case .post:
            return MessageConst.NOTIFICATION.POST_FAVORITE_ERROR
        case .get:
            return MessageConst.NOTIFICATION.GET_FAVORITE_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_FAVORITE_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_FAVORITE_ERROR
        }
    }
}

protocol FavoriteDataModelProtocol {
    var rx_action: PublishSubject<FavoriteDataModelAction> { get }
    var rx_error: PublishSubject<FavoriteDataModelError> { get }
    func insert(favorites: [Favorite])
    func select() -> [Favorite]
    func select(id: String) -> [Favorite]
    func select(url: String) -> [Favorite]
    func delete()
    func delete(favorites: [Favorite])
    func reload(currentTab: Tab)
    func update(currentTab: Tab)
    func fetch(request: GetFavoriteRequest)
    func post(request: PostFavoriteRequest)
}

final class FavoriteDataModel: FavoriteDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<FavoriteDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<FavoriteDataModelError>()

    private let disposeBag = DisposeBag()

    static let s = FavoriteDataModel()

    /// 更新有無フラグ(更新されていればサーバーと同期する)
    var isUpdated = false

    /// DBリポジトリ
    private let repository = DBRepository()

    private init() {}

    func insert(favorites: [Favorite]) {
        let result = repository.insert(data: favorites)

        if case .success = result {
            rx_action.onNext(.insert(favorites: favorites))
        } else {
            rx_error.onNext(.store)
        }
    }

    func select() -> [Favorite] {
        let result = repository.select(Favorite.self)
        if case let .success(favorite) = result {
            return favorite
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func select(id: String) -> [Favorite] {
        let result = repository.select(Favorite.self)
        if case let .success(favorite) = result {
            return favorite.filter({ $0.id == id })
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func select(url: String) -> [Favorite] {
        let result = repository.select(Favorite.self)
        if case let .success(favorite) = result {
            return favorite.filter({ $0.url == url })
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        let result = repository.delete(data: select())
        if case .success = result {
            rx_action.onNext(.deleteAll)
        } else {
            rx_error.onNext(.delete)
        }
    }

    func delete(favorites: [Favorite]) {
        let result = repository.delete(data: favorites)
        if case .success = result {
            rx_action.onNext(.delete)
        } else {
            rx_error.onNext(.delete)
        }
    }

    /// お気に入りの更新チェック
    func reload(currentTab: Tab) {
        rx_action.onNext(.reload(url: currentTab.url))
    }

    /// update favorite
    func update(currentTab: Tab) {
        if !currentTab.url.isEmpty && !currentTab.title.isEmpty {
            let fd = Favorite()
            fd.title = currentTab.title
            fd.url = currentTab.url

            if let favorite = select(url: fd.url).first {
                // すでに登録済みの場合は、お気に入りから削除する
                delete(favorites: [favorite])
            } else {
                insert(favorites: [fd])
            }
        } else {
            rx_error.onNext(.get)
        }
    }

    /// 記事取得
    func fetch(request: GetFavoriteRequest) {
        let repository = ApiRepository<App>()

        repository.rx.request(.getFavorite(request: request))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> GetFavoriteResponse? in

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let favoriteResponse: GetFavoriteResponse = try decoder.decode(GetFavoriteResponse.self, from: response.data)
                    return favoriteResponse
                } catch {
                    return nil
                }
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    if let response = response, response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                        log.debug("get favorite success.")
                        let favorites = response.data.map {$0}
                        // initialize data
                        _ = self.repository.delete(data: self.select())
                        _ = self.repository.insert(data: favorites)
                        self.rx_action.onNext(.fetch(favorites: favorites))
                    } else {
                        log.error("get favorite error. code: \(response?.code ?? "")")
                        self.rx_error.onNext(.fetch)
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("get favorite error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.fetch)
            })
            .disposed(by: disposeBag)
    }

    /// 記事取得
    func post(request: PostFavoriteRequest) {
        let repository = ApiRepository<App>()

        repository.rx.request(.postFavorite(request: request))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> PostFavoriteResponse? in

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let favoriteResponse: PostFavoriteResponse = try decoder.decode(PostFavoriteResponse.self, from: response.data)
                    return favoriteResponse
                } catch {
                    return nil
                }
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    if let response = response, response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                        log.debug("post favorite success.")
                        self.rx_action.onNext(.post)
                    } else {
                        log.error("post favorite error. code: \(response?.code ?? "")")
                        self.rx_error.onNext(.post)
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("post favorite error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.post)
            })
            .disposed(by: disposeBag)
    }
}
