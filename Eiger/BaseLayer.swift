//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class BaseLayer: UIView, HeaderViewDelegate, BaseViewDelegate {
    
    private let headerView: HeaderView = HeaderView()
    private let footerView: FooterView = FooterView(frame: CGRect(x: 0, y: DeviceDataManager.shared.displaySize.height - AppDataManager.shared.thumbnailSize.height, width: DeviceDataManager.shared.displaySize.width, height: AppDataManager.shared.thumbnailSize.height))
    private let baseView: BaseView = BaseView()
    private var overlay: UIButton? = nil
    
    // 次のタッチを受け付けるまで、headerのアニメーションを強制Stopするフラグ
    private var slideForceStopFlag = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        baseView.frame = CGRect(x: 0, y: DeviceDataManager.shared.statusBarHeight, width: frame.size.width, height: frame.size.height - AppDataManager.shared.thumbnailSize.height - DeviceDataManager.shared.statusBarHeight)
        baseView.delegate = self
        // サイズが可変なので、layoutSubViewsで初期化しない
        headerView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: DeviceDataManager.shared.statusBarHeight)
        headerView.delegate = self
        
        addSubview(baseView)
        addSubview(headerView)
        addSubview(footerView)
        
        /* テストコード */
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 100), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("戻る(ページ)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryBackWebView, object: nil)
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 100), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(ページ)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryForwardWebView, object: nil)
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 180), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("戻る(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 180), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 260), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("リロード", for: .normal)
            // TODO: リロードは自前で管理しているURLから実施する
            _ = button.reactive.tap
                .observe { _ in
                    NotificationCenter.default.post(name: .baseViewModelWillReloadWebView, object: nil)
            }
            addSubview(button)
        }

        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 340), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("wv作成・移動", for: .normal)
            // TODO: リロードは自前で管理しているURLから実施する
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 340), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("現在のwv削除", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
            }
            addSubview(button)
        }
        /*-----------*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Private Method
    
    private func resizeHeaderToMax() {
        headerView.resizeToMax()
        baseView.frame.origin.y = headerView.heightMax
    }
    
    private func resizeHeaderToMin() {
        headerView.resizeToMin()
        baseView.frame.origin.y = DeviceDataManager.shared.statusBarHeight
    }
    
    private func slide(val: CGFloat) {
        if !slideForceStopFlag {
            headerView.resize(value: val)
            baseView.frame.origin.y += val
            baseView.scroll(pt: -val)
        }
    }
// MARK: HeaderView Delegate
    
    func headerViewDidBeginEditing() {
        overlay = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: self.headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - self.headerView.frame.size.height)))
        overlay!.backgroundColor = UIColor.gray
        _ = overlay!.reactive.controlEvents(.touchDown)
            .observeNext { [weak self] _ in
                self!.overlay!.removeFromSuperview()
                self!.overlay = nil
                self!.headerView.finishEditing(force: true)
        }
        addSubview(overlay!)
    }
    
    func headerViewDidEndEditing() {
        overlay!.removeFromSuperview()
        overlay = nil
        headerView.finishEditing(force: false)
    }
    
// MARK: BaseView Delegate
    
    func baseViewDidTouch(touch: Bool) {
        // タッチ終了時にheaderViewのサイズを調整する
        if touch {
            slideForceStopFlag = false
        }
        
        if !touch && headerView.resizing {
            // TODO: resizing判定を見直す。スクロール後に変な位置でheaderviewが止まる
            slideForceStopFlag = true
            if headerView.frame.size.height > headerView.heightMax / 2 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.resizeHeaderToMax()
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.resizeHeaderToMin()
                })
            }
        }
    }
    
    func baseViewDidScroll(speed: CGFloat) {
        if speed > 0 {
            // headerViewを拡大、baseViewを縮小
            if headerView.frame.size.height != headerView.heightMax {
                if headerView.frame.size.height + speed > headerView.heightMax {
                    resizeHeaderToMax()
                } else {
                    slide(val: speed)
                }
            }
        } else if speed < 0 {
            // headerを縮小、baseViewを拡大
            if headerView.frame.size.height != DeviceDataManager.shared.statusBarHeight {
                if headerView.frame.size.height + speed < DeviceDataManager.shared.statusBarHeight {
                    resizeHeaderToMin()
                } else {
                    slide(val: speed)
                }
            }
        }
        headerView.frame.origin.y = 0
    }
}
