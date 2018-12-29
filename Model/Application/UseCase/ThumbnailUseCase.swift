//
//  ThumbnailUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum ThumbnailUseCaseAction {
    case append(pageHistory: PageHistory)
    case insert(at: Int, pageHistory: PageHistory)
    case change(context: String)
    case delete(deleteContext: String, currentContext: String?, deleteIndex: Int)
}

/// フッターユースケース
public final class ThumbnailUseCase {
    public static let s = ThumbnailUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<ThumbnailUseCaseAction>()
    
    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupRx()
    }

    private func setupRx() {
        PageHistoryDataModel.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self else { return }
                if let action = action.element {
                    switch action {
                    case let .insert(pageHistory, at):
                        self.rx_action.onNext(.insert(at: at, pageHistory: pageHistory))
                    case let .append(pageHistory): self.rx_action.onNext(.append(pageHistory: pageHistory))
                    case let .change(context): self.rx_action.onNext(.change(context: context))
                    case let .delete(deleteContext, currentContext, deleteIndex):
                        self.rx_action.onNext(.delete(deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex))
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
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
