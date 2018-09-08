//
//  ScrollUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// スクロールユースケース
public final class ScrollUseCase {
    public static let s = ScrollUseCase()

    /// スクロールアップ通知用RX
    public let rx_scrollUseCaseDidRequestScrollUp = PublishSubject<()>()
    /// 自動スクロール通知用RX
    public let rx_scrollUseCaseDidRequestAutoScroll = PublishSubject<()>()

    public var autoScrollInterval: CGFloat {
        get {
            return CGFloat(SettingDataModel.s.autoScrollInterval)
        }
        set(value) {
            SettingDataModel.s.autoScrollInterval = Float(value)
        }
    }

    private init() {}

    /// スクロールアップ
    public func scrollUp() {
        rx_scrollUseCaseDidRequestScrollUp.onNext(())
    }

    /// 自動スクロール
    public func autoScroll() {
        rx_scrollUseCaseDidRequestAutoScroll.onNext(())
    }
}
