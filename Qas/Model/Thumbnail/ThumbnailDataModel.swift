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

    func getThumbnail(context: String) -> UIImage? {
        let image = UIImage(contentsOfFile: Util.thumbnailUrl(folder: context).path)
        return image?.crop(w: Int(AppConst.BASE_LAYER_THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER_THUMBNAIL_SIZE.width * 2) * DeviceConst.ASPECT_RATE))
    }
    
    func getCapture(context: String) -> UIImage? {
        return UIImage(contentsOfFile: Util.thumbnailUrl(folder: context).path)
    }
    
    /// サムネイルデータの削除
    func delete(context: String) {
        Util.deleteFolder(path: Util.thumbnailPath(folder: context))
    }
    
    /// サムネイルデータの全削除
    func delete() {
        Util.deleteFolder(path: AppConst.PATH_THUMBNAIL)
        Util.createFolder(path: AppConst.PATH_THUMBNAIL)
    }
}
