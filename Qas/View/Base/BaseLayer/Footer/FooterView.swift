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
    
    private var viewModel = FooterViewModel(index: UserDefaults.standard.integer(forKey: AppConst.KEY_LOCATION_INDEX))
    private let scrollView = UIScrollView()
    private var thumbnails: [Thumbnail] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel.delegate = self
        
        addAreaShadow()
        
        backgroundColor = UIColor.pastelLightGray
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y:0), size: frame.size)
        scrollView.delegate = self
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
        
        // 初期ロード
        load()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                let tappedContext = btn.context
                if tappedContext == self.viewModel.currentContext {
                    log.debug("selected same page.")
                } else {
                    self.viewModel.changePageHistoryDataModel(context: btn.context)
                }
            })
            .disposed(by: rx.disposeBag)
        
        let longPressRecognizer = UILongPressGestureRecognizer()

        // ロングプレス
        longPressRecognizer.rx.event
            .subscribe { [weak self] sender in
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
                guard let `self` = self else { return }
                let tappedContext = btn.context
                if tappedContext == self.viewModel.currentContext {
                    log.debug("selected same page.")
                } else {
                    self.viewModel.changePageHistoryDataModel(context: btn.context)
                }
            })
            .disposed(by: rx.disposeBag)
        
        let longPressRecognizer = UILongPressGestureRecognizer()

        // ロングプレス
        longPressRecognizer.rx.event
            .subscribe{ [weak self] sender in
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

// MARK: FooterViewModel Delegate
extension FooterView: FooterViewModelDelegate {
    func footerViewModelDidChangeThumbnail(context: String) {
        updateFrontBar()
    }
    
    func footerViewModelDidAppendThumbnail(pageHistory: PageHistory) {
        // 新しいサムネイルスペースを作成
        let _ = append(context: pageHistory.context)
        updateFrontBar()
    }
    
    func footerViewModelDidInsertThumbnail(at: Int, pageHistory: PageHistory) {
        // 新しいサムネイルスペースを作成
        let _ = insert(at: at, context: pageHistory.context)
        updateFrontBar()
    }
    
    func footerViewModelDidRemoveThumbnail(context: String, pageExist: Bool) {
        let deleteIndex = D.findIndex(thumbnails, callback: { $0.context == context })!

        if ((self.thumbnails.count).f * AppConst.BASE_LAYER_THUMBNAIL_SIZE.width > self.scrollView.frame.size.width) {
            self.scrollView.contentSize.width -= AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2
            self.scrollView.contentInset =  UIEdgeInsetsMake(0, self.scrollView.contentInset.left - (AppConst.BASE_LAYER_THUMBNAIL_SIZE.width / 2), 0, 0)
        }
        
        thumbnails[deleteIndex].removeFromSuperview()
        thumbnails.remove(at: deleteIndex)
        updateFrontBar()
        
        if thumbnails.count > 0 {
            UIView.animate(withDuration: 0.3, animations: {
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
    
    func footerViewModelDidStartLoading(context: String) {
        startIndicator(context: context)
    }
    
    func footerViewModelDidEndLoading(context: String, title: String) {
        // くるくるを止めて、サムネイルを表示する
        let targetThumbnail: Thumbnail = self.thumbnails.filter({ (thumbnail) -> Bool in
            return thumbnail.context == context
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
                targetThumbnail.setThumbnailTitle(title: title)
                if let image = ThumbnailDataModel.s.getThumbnail(context: context) {
                    targetThumbnail.setImage(nil, for: .normal)
                    targetThumbnail.setBackgroundImage(image, for: .normal)
                } else {
                    log.error("missing thumbnail image")
                }
            }
        }
    }
}
