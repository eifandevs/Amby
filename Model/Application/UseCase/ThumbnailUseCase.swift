//
//  ThumbnailUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// フッターユースケース
public final class ThumbnailUseCase {
    public static let s = ThumbnailUseCase()

    private init() {}

    public func getCapture(context: String) -> UIImage? {
        return ThumbnailDataModel.s.getCapture(context: context)
    }

    /// create thumbnail folder
    public func createFolder(context: String) {
        ThumbnailDataModel.s.create(context: context)
    }

    /// write thumbnail data
    public func write(context: String, data: Data) {
        ThumbnailDataModel.s.write(context: context, data: data)
    }

    public func delete() {
        ThumbnailDataModel.s.delete()
    }

    /// サムネイルの削除
    public func delete(context: String) {
        ThumbnailDataModel.s.delete(context: context)
    }

    public func getThumbnail(context: String) -> UIImage? {
        return ThumbnailDataModel.s.getThumbnail(context: context)
    }
}
