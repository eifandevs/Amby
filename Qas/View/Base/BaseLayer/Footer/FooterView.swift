//
//  FooterView.swift
//  Eiger
//
//  Created by temma on 2017/03/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import RxSwift
import RxCocoa
import NSObject_Rx

class FooterView: UIView, ShadowView {
    
    private var viewModel = FooterViewModel()
    private let scrollView = UIScrollView()
    private var thumbnails: [Thumbnail] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addAreaShadow()
        
        backgroundColor = UIColor.pastelLightGray
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y:0), size: frame.size)
        scrollView.delegate = self // スクロールビューはなんか怖いのでrx化しない
        scrollView.contentSize = CGSize(width: frame.size.width + 1, height: frame.size.height)
        scrollView.bounces = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        addSubview(scrollView)
        // サムネイル説明用に、スクロールビューの領域外に配置できるようにする
        scrollView.clipsToBounds = false
        
        // サムネイル追加監視
        viewModel.rx_footerViewModelDidAppendThumbnail
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_footerViewModelDidAppendThumbnail")
                guard let `self` = self else { return }
                if let pageHistory = object.element {
                    // 新しいサムネイルスペースを作成
                    let _ = self.append(context: pageHistory.context)
                    self.updateFrontBar()
                }
                log.eventOut(chain: "rx_footerViewModelDidAppendThumbnail")
            }
            .disposed(by: rx.disposeBag)
        
        // サムネイル変更監視
        viewModel.rx_footerViewModelDidChangeThumbnail
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_footerViewModelDidChangeThumbnail")
                guard let `self` = self else { return }
                self.updateFrontBar()
                log.eventOut(chain: "rx_footerViewModelDidChangeThumbnail")
            }
            .disposed(by: rx.disposeBag)
        
        // サムネイルインサート監視
        viewModel.rx_footerViewModelDidInsertThumbnail
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_footerViewModelDidInsertThumbnail")
                guard let `self` = self else { return }
                if let tuple = object.element {
                    // 新しいサムネイルスペースを作成
                    let _ = self.insert(at: tuple.at, context: tuple.pageHistory.context)
                    self.updateFrontBar()
                }
                log.eventOut(chain: "rx_footerViewModelDidInsertThumbnail")
            }
            .disposed(by: rx.disposeBag)
        
        // サムネイル削除監視
        viewModel.rx_footerViewModelDidRemoveThumbnail
            .observeOn(MainScheduler.asyncInstance) // アニメーションさせるのでメインスレッドで実行
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_footerViewModelDidRemoveThumbnail")
                // TODO: キュー管理する
                guard let `self` = self else { return }
                if let tuple = object.element {
                    let deleteIndex = D.findIndex(self.thumbnails, callback: { $0.context == tuple.context })!
                    
                    self.thumbnails[deleteIndex].removeFromSuperview()
                    self.thumbnails.remove(at: deleteIndex)
                    self.updateFrontBar()
                    
                    if self.thumbnails.count == 0 {
                        if ((self.thumbnails.count + 1).f * AppConst.BASE_LAYER_THUMBNAIL_SIZE.width > self.scrollView.frame.size.width) {
                            self.scrollView.contentSize.width -= AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2
                            self.scrollView.contentInset =  UIEdgeInsetsMake(0, self.scrollView.contentInset.left - (AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2), 0, 0)
                        }
                    } else {
                        UIView.animate(withDuration: 0.3, animations: {
                            if ((self.thumbnails.count + 1).f * AppConst.BASE_LAYER_THUMBNAIL_SIZE.width > self.scrollView.frame.size.width) {
                                self.scrollView.contentSize.width -= AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2
                                self.scrollView.contentInset =  UIEdgeInsetsMake(0, self.scrollView.contentInset.left - (AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2), 0, 0)
                            }
                            
                            for i in 0...self.thumbnails.count - 1 {
                                if i < deleteIndex {
                                    self.thumbnails[i].center.x += self.thumbnails[i].frame.size.width / 2
                                } else if i >= deleteIndex {
                                    self.thumbnails[i].center.x -= self.thumbnails[i].frame.size.width / 2
                                }
                            }
                        })
                    }
                }
                log.eventOut(chain: "rx_footerViewModelDidRemoveThumbnail")
            }
            .disposed(by: rx.disposeBag)
        
        // ローディングスタート監視
        viewModel.rx_footerViewModelDidStartLoading
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_footerViewModelDidStartLoading")
                guard let `self` = self else { return }
                if let context = object.element {
                    self.startIndicator(context: context)
                }
                log.eventOut(chain: "rx_footerViewModelDidStartLoading")
            }
            .disposed(by: rx.disposeBag)
        
        // ローティング終了監視
        viewModel.rx_footerViewModelDidEndLoading
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_footerViewModelDidEndLoading")
                guard let `self` = self else { return }
                if let tuple = object.element {
                    // くるくるを止めて、サムネイルを表示する
                    let targetThumbnail: Thumbnail = self.thumbnails.filter({ (thumbnail) -> Bool in
                        return thumbnail.context == tuple.context
                    })[0]
                    let existIndicator = targetThumbnail.subviews.filter { (view) -> Bool in return view is NVActivityIndicatorView }.count > 0
                    if existIndicator {
                        DispatchQueue.mainSyncSafe { [weak self] in
                            guard let _ = self else { return }
                            targetThumbnail.subviews.forEach({ (v) in
                                if NSStringFromClass(type(of: v)) == "NVActivityIndicatorView.NVActivityIndicatorView" {
                                    let indicator = v as! NVActivityIndicatorView
                                    indicator.stopAnimating()
                                    indicator.alpha = 0
                                    indicator.removeFromSuperview()
                                }
                            })
                            targetThumbnail.setThumbnailTitle(title: tuple.title)
                            if let image = ThumbnailDataModel.s.getThumbnail(context: tuple.context) {
                                targetThumbnail.setImage(nil, for: .normal)
                                targetThumbnail.setBackgroundImage(image, for: .normal)
                            } else {
                                log.error("missing thumbnail image")
                            }
                        }
                    }
                }
                log.eventOut(chain: "rx_footerViewModelDidEndLoading")
            }
            .disposed(by: rx.disposeBag)
        // 初期ロード
        load()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        log.debug("deinit called.")
    }
// MARK: Private Method
    
    /// 現在地にスクロール
    private func scrollAtCurrent() {
        var ptX = -scrollView.contentInset.left + (viewModel.currentLocation.f * AppConst.BASE_LAYER_THUMBNAIL_SIZE.width)
        if ptX > scrollView.contentSize.width - frame.width + scrollView.contentInset.right {
            ptX = scrollView.contentSize.width - frame.width + scrollView.contentInset.right
        }
        let offset = CGPoint(x: ptX, y: scrollView.contentOffset.y)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    /// 初期ロード
    private func load() {
        let pageHistories = viewModel.pageHistories
        if pageHistories.count > 0 {
            for (index, item) in pageHistories.enumerated() {
                let btn = append(context: item.context)
                if !item.context.isEmpty {
                    // コンテキストが存在しないのは、新規作成後にwebview作らずにアプリを終了した場合
                    if let image = ThumbnailDataModel.s.getThumbnail(context: item.context) {
                        btn.setImage(nil, for: .normal)
                        btn.setBackgroundImage(image, for: .normal)
                        btn.setThumbnailTitle(title: item.title)
                    }
                }
            }
        }
        updateFrontBar()
        // スクロールする
        scrollAtCurrent()
    }
    
    /// 新しいサムネイル追加
    private func append(context: String) -> Thumbnail {
        // 後ろに追加
        let additionalPointX = ((thumbnails.count).f * AppConst.BASE_LAYER_THUMBNAIL_SIZE.width) - (thumbnails.count - 1 < 0 ? 0 : thumbnails.count - 1).f * AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2
        let btn = Thumbnail(frame: CGRect(origin: CGPoint(x: (frame.size.width / 2) - (AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2.0) + additionalPointX, y: 0), size: AppConst.BASE_LAYER_THUMBNAIL_SIZE))
        btn.backgroundColor = UIColor.darkGray
        btn.setImage(image: R.image.footer_back(), color: UIColor.gray)
        let inset: CGFloat = btn.frame.size.width / 9
        btn.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        // ボタンタップ
        btn.rx.tap
            .subscribe { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                let tappedContext = btn.context
                if tappedContext == self.viewModel.currentContext {
                    log.debug("selected same page.")
                } else {
                    self.viewModel.changePageHistoryDataModel(context: btn.context)
                }
                log.eventIn(chain: "rx_tap")
            }
            .disposed(by: rx.disposeBag)
        
        let longPressRecognizer = UILongPressGestureRecognizer()

        // ロングプレス
        longPressRecognizer.rx.event
            .subscribe { [weak self] sender in
                log.eventIn(chain: "rx_longPress")
                guard let `self` = self else { return }
                if let sender = sender.element {
                    if sender.state == .began {
                        for (_, thumbnail) in self.thumbnails.enumerated() {
                            if sender.view == thumbnail {
                                self.viewModel.removePageHistoryDataModel(context: thumbnail.context)
                                break
                            }
                        }
                    }
                }
                log.eventOut(chain: "rx_longPress")
            }
            .disposed(by: rx.disposeBag)

        btn.addGestureRecognizer(longPressRecognizer)

        btn.context = context
        thumbnails.append(btn)
        
        // スクロールビューのコンテンツサイズを大きくする
        if ((thumbnails.count).f * btn.frame.size.width > scrollView.frame.size.width) {
            scrollView.contentSize.width += btn.frame.size.width / 2
            scrollView.contentInset =  UIEdgeInsetsMake(0, scrollView.contentInset.left + (btn.frame.size.width / 2), 0, 0)
        }
        
        scrollView.addSubview(btn)
        
        if thumbnails.count > 1 {
            for thumbnail in thumbnails {
                UIView.animate(withDuration: 0.3, animations: {
                    thumbnail.center.x -= thumbnail.frame.size.width / 2
                })
            }
        }
        scrollView.scroll(to: .right, animated: true)
        return btn
    }
    
    /// 新しいサムネイル挿入
    private func insert(at: Int, context: String) -> Thumbnail {

        // スペースを空けるアニメーション
        if thumbnails.count > 1 {
            for (index, thumbnail) in thumbnails.enumerated() {
                if index < at {
                    UIView.animate(withDuration: 0.3, animations: {
                        thumbnail.center.x -= thumbnail.frame.size.width / 2
                    })
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        thumbnail.center.x += thumbnail.frame.size.width / 2
                    })
                }
            }
        }
        
        // 間に挿入
        let preBtn = thumbnails[at - 1] // 左隣のボタン
        let btn = Thumbnail(frame: CGRect(origin: CGPoint(x: preBtn.frame.origin.x + AppConst.BASE_LAYER_THUMBNAIL_SIZE.width, y: AppConst.BASE_LAYER_THUMBNAIL_SIZE.height), size: AppConst.BASE_LAYER_THUMBNAIL_SIZE))
        btn.backgroundColor = UIColor.darkGray
        btn.setImage(image: R.image.footer_back(), color: UIColor.gray)
        let inset: CGFloat = btn.frame.size.width / 9
        btn.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)

        // ボタンタップ
        btn.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                let tappedContext = btn.context
                if tappedContext == self.viewModel.currentContext {
                    log.debug("selected same page.")
                } else {
                    self.viewModel.changePageHistoryDataModel(context: btn.context)
                }
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: rx.disposeBag)
        
        let longPressRecognizer = UILongPressGestureRecognizer()

        // ロングプレス
        longPressRecognizer.rx.event
            .subscribe{ [weak self] sender in
                log.eventIn(chain: "rx_longPress")
                guard let `self` = self else { return }
                if let sender = sender.element {
                    if sender.state == .began {
                        for (_, thumbnail) in self.thumbnails.enumerated() {
                            if sender.view == thumbnail {
                                self.viewModel.removePageHistoryDataModel(context: thumbnail.context)
                                break
                            }
                        }
                    }
                }
                log.eventOut(chain: "rx_longPress")
            }
            .disposed(by: rx.disposeBag)

        btn.addGestureRecognizer(longPressRecognizer)
        btn.context = context
        thumbnails.insert(btn, at: at)

        // スクロールビューのコンテンツサイズを大きくする
        if ((thumbnails.count).f * btn.frame.size.width > scrollView.frame.size.width) {
            scrollView.contentSize.width += btn.frame.size.width / 2
            scrollView.contentInset =  UIEdgeInsetsMake(0, scrollView.contentInset.left + (btn.frame.size.width / 2), 0, 0)
        }
        
        scrollView.addSubview(btn)

        // 挿入アニメーション
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
            btn.frame.origin.y = 0
        }, completion: nil)
        
        scrollAtCurrent()
        
        return btn
    }
    
    private func startIndicator(context: String) {
        let targetThumbnail = D.find(thumbnails, callback: { $0.context == context })!
        // くるくるを表示する
        let existIndicator = targetThumbnail.subviews.filter { (view) -> Bool in return view is NVActivityIndicatorView }.count > 0
        if !existIndicator {
            let rect = CGRect(x: 0, y: 0, width: AppConst.BASE_LAYER_THUMBNAIL_SIZE.height * 0.7, height: AppConst.BASE_LAYER_THUMBNAIL_SIZE.height * 0.7)
            let indicator = NVActivityIndicatorView(frame: rect, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.brilliantBlue, padding: 0)
            indicator.center = CGPoint(x: targetThumbnail.bounds.size.width / 2, y: targetThumbnail.bounds.size.height / 2)
            indicator.isUserInteractionEnabled = false
            targetThumbnail.addSubview(indicator)
            indicator.startAnimating()
        }
    }
    
    /// フロントバーの変更
    private func updateFrontBar() {
        thumbnails.forEach({ $0.isFront = $0.context == viewModel.currentContext ? true : false })
    }
}

// MARK: ScrollView Delegate
extension FooterView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        thumbnails.forEach { (thumbnail) in
            UIView.animate(withDuration: 0.2, animations: {
                thumbnail.thumbnailInfo.alpha = 1
            })
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        thumbnails.forEach { (thumbnail) in
            UIView.animate(withDuration: 0.2, animations: {
                thumbnail.thumbnailInfo.alpha = 0
            })
        }
    }
}
