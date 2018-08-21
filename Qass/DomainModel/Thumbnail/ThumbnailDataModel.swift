//
//  ThumbnailDataModel.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

final class ThumbnailDataModel {
    static let s = ThumbnailDataModel()

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    func getThumbnail(context: String) -> UIImage? {
        let image = localStorageRepository.getImage(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"))
        return image?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * DeviceConst.DEVICE.ASPECT_RATE))
    }

    func getCapture(context: String) -> UIImage? {
        return localStorageRepository.getImage(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"))
    }

    /// サムネイルデータの削除
    func delete(context: String) {
        localStorageRepository.delete(.thumbnails(additionalPath: context, resource: nil))
    }

    /// サムネイルデータの全削除
    func delete() {
        localStorageRepository.delete(.thumbnails(additionalPath: nil, resource: nil))
        localStorageRepository.create(.thumbnails(additionalPath: nil, resource: nil))
    }

    /// create folder
    func create(context: String) {
        localStorageRepository.create(.thumbnails(additionalPath: context, resource: nil))
    }

    /// write
    func write(context: String, data: Data) {
        localStorageRepository.write(.thumbnails(additionalPath: "\(context)", resource: "thumbnail.png"), data: data)
    }
}
