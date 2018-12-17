//
//  ThumbnailDataModel.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

enum ThumbnailDataModelError {
    case delete
    case write
    case create
}

extension ThumbnailDataModelError: ModelError {
    var message: String {
        switch self {
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_THUMBNAIL_ERROR
        case .write:
            return MessageConst.NOTIFICATION.STORE_THUMBNAIL_ERROR
        case .create:
            return MessageConst.NOTIFICATION.CREATE_THUMBNAIL_ERROR
        }
    }
}

final class ThumbnailDataModel {
    static let s = ThumbnailDataModel()

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    /// エラー通知用RX
    let rx_error = PublishSubject<ThumbnailDataModelError>()

    private init() {}

    func getThumbnail(context: String) -> UIImage? {
        let result = localStorageRepository.getImage(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"))

        if case let .success(image) = result {
            return image
        } else {
            return nil
        }
    }

    func getCapture(context: String) -> UIImage? {
        let result = localStorageRepository.getImage(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"))

        if case let .success(image) = result {
            return image
        } else {
            return nil
        }
    }

    /// サムネイルデータの削除
    func delete(context: String) {
        log.debug("delete thumbnail. context: \(context)")
        let result = localStorageRepository.delete(.thumbnails(additionalPath: context, resource: nil))

        if case .failure = result {
            rx_error.onNext(.delete)
        }
    }

    /// サムネイルデータの全削除
    func delete() {
        let deleteResult = localStorageRepository.delete(.thumbnails(additionalPath: nil, resource: nil))
        if case .failure = deleteResult {
            rx_error.onNext(.delete)
        }

        let createResult = localStorageRepository.create(.thumbnails(additionalPath: nil, resource: nil))
        if case .failure = createResult {
            rx_error.onNext(.create)
        }
    }

    /// create folder
    func create(context: String) {
        let result = localStorageRepository.create(.thumbnails(additionalPath: context, resource: nil))
        if case .failure = result {
            rx_error.onNext(.create)
        }
    }

    /// write
    func write(context: String, data: Data) {
        let result = localStorageRepository.write(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"), data: data)
        if case .failure = result {
            rx_error.onNext(.write)
        }
    }
}
