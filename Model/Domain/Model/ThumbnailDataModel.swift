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
            return MessageConst.NOTIFICATION.DELETE_PAGE_HISTORY_ERROR
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
        let image = localStorageRepository.getImage(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"))
        return image
    }

    func getCapture(context: String) -> UIImage? {
        return localStorageRepository.getImage(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"))
    }

    /// サムネイルデータの削除
    func delete(context: String) {
        log.debug("delete thumbnail. context: \(context)")
        let result = localStorageRepository.delete(.thumbnails(additionalPath: context, resource: nil))
        switch result {
        case .success:
            break
        case .failure:
            rx_error.onNext(.delete)
        }
    }

    /// サムネイルデータの全削除
    func delete() {
        _ = localStorageRepository.delete(.thumbnails(additionalPath: nil, resource: nil))
        _ = localStorageRepository.create(.thumbnails(additionalPath: nil, resource: nil))
    }

    /// create folder
    func create(context: String) {
        _ = localStorageRepository.create(.thumbnails(additionalPath: context, resource: nil))
    }

    /// write
    func write(context: String, data: Data) {
        let result = localStorageRepository.write(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"), data: data)
        switch result {
        case .success:
            break
        case .failure:
            rx_error.onNext(.write)
        }
    }
}
