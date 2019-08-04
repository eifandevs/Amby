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

    /// models
    private var thumbnailDataModel: ThumbnailDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        thumbnailDataModel = ThumbnailDataModel.s
    }

    public func getCapture(context: String) -> UIImage? {
        return thumbnailDataModel.getCapture(context: context)
    }

    /// create thumbnail folder
    public func createFolder(context: String) {
        thumbnailDataModel.create(context: context)
    }

    /// write thumbnail data
    public func write(context: String, data: Data) {
        thumbnailDataModel.write(context: context, data: data)
    }

    public func delete() {
        thumbnailDataModel.delete()
    }

    /// サムネイルの削除
    public func delete(context: String) {
        thumbnailDataModel.delete(context: context)
    }

    public func getThumbnail(context: String) -> UIImage? {
        return thumbnailDataModel.getThumbnail(context: context)
    }
}
