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

class FooterView: UIView, ShadowView, FooterViewModelDelegate {
    
    private var viewModel = FooterViewModel(index: UserDefaults.standard.integer(forKey: AppConst.locationIndexKey))
    private let scrollView = UIScrollView()
    private var thumbnails: [Thumbnail] = []
    
    private var frontThumbnail: Thumbnail {
        get {
            return thumbnails[viewModel.locationIndex]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel.delegate = self
        
        addAreaShadow()
        
        backgroundColor = UIColor.pastelLightGray
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y:0), size: frame.size)
        scrollView.contentSize = CGSize(width: frame.size.width + 1, height: frame.size.height)
        scrollView.bounces = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        addSubview(scrollView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Private Method
    
    private func createCaptureSpace(context: String, isPrivateMode: Bool) -> Thumbnail {
        let additionalPointX = ((thumbnails.count).cgfloat * AppConst.thumbnailSize.width) - (thumbnails.count - 1 < 0 ? 0 : thumbnails.count - 1).cgfloat * AppConst.thumbnailSize.width / 2
        let btn = Thumbnail(frame: CGRect(origin: CGPoint(x: (frame.size.width / 2) - (AppConst.thumbnailSize.width / 2.0) + additionalPointX, y: 0), size: AppConst.thumbnailSize), isPrivateMode: isPrivateMode)
        btn.backgroundColor = UIColor.darkGray
        btn.setImage(image: R.image.footer_back(), color: UIColor.gray)
        btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        btn.addTarget(self, action: #selector(self.onTappedThumbnail(_:)), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        btn.addGestureRecognizer(longPressRecognizer)
        btn.context = context
        thumbnails.append(btn)
        
        if ((thumbnails.count).cgfloat * btn.frame.size.width > scrollView.frame.size.width) {
            // スクロールビューのコンテンツサイズを大きくする
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
        updateFrontBar()
        return btn
    }
    
    private func startIndicator() {
        // くるくるを表示する
        let existIndicator = frontThumbnail.subviews.filter { (view) -> Bool in return view is NVActivityIndicatorView }.count > 0
        if !existIndicator {
            let rect = CGRect(x: 0, y: 0, width: AppConst.thumbnailSize.height * 0.7, height: AppConst.thumbnailSize.height * 0.7)
            let indicator = NVActivityIndicatorView(frame: rect, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.brilliantBlue, padding: 0)
            indicator.center = CGPoint(x: frontThumbnail.bounds.size.width / 2, y: frontThumbnail.bounds.size.height / 2)
            indicator.isUserInteractionEnabled = false
            frontThumbnail.addSubview(indicator)
            indicator.startAnimating()
        }
    }
    
    /// フロントバーの変更
    private func updateFrontBar() {
        for (index, thumbnail) in thumbnails.enumerated() {
            if index == viewModel.locationIndex {
                thumbnail.isFront = true
            } else {
                thumbnail.isFront = false
            }
        }
    }

// MARK: FooterViewModel Delegate

    func footerViewModelDidAddThumbnail(context: String, isPrivateMode: Bool) {
        // 新しいサムネイルスペースを作成
        let _ = createCaptureSpace(context: context, isPrivateMode: isPrivateMode)
    }
    
    func footerViewModelDidChangeThumbnail() {
        updateFrontBar()
    }
    
    func footerViewModelDidRemoveThumbnail(index: Int) {
        let completion: (() -> ()) = { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.thumbnails[index].removeFromSuperview()
            self.thumbnails.remove(at: index)
            self.updateFrontBar()
        }
        if thumbnails.count > 1 {
            thumbnails[index].alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                for i in 0...self.thumbnails.count - 1 {
                    if i < index {
                        self.thumbnails[i].center.x += self.thumbnails[i].frame.size.width / 2
                    } else if i > index {
                        self.thumbnails[i].center.x -= self.thumbnails[i].frame.size.width / 2
                    }
                }
                if ((self.thumbnails.count).cgfloat * AppConst.thumbnailSize.width > self.scrollView.frame.size.width) {
                    self.scrollView.contentSize.width -= AppConst.thumbnailSize.width / 2
                    self.scrollView.contentInset =  UIEdgeInsetsMake(0, self.scrollView.contentInset.left - (AppConst.thumbnailSize.width / 2), 0, 0)
                }
            }, completion: { (isFinish) in
                completion()
            })
        } else {
            // 最後のwebview削除の場合は、速攻削除する
            completion()
        }
    }
    
    func footerViewModelDidStartLoading(index: Int) {
        startIndicator()
    }
    
    func footerViewModelDidEndLoading(context: String, index: Int) {
        // くるくるを止めて、サムネイルを表示する
        let existIndicator = frontThumbnail.subviews.filter { (view) -> Bool in return view is NVActivityIndicatorView }.count > 0
        if existIndicator {
            DispatchQueue.mainSyncSafe { [weak self] _ in
                guard let `self` = self else { return }
                let targetThumbnail: Thumbnail = self.thumbnails.filter({ (thumbnail) -> Bool in
                    return thumbnail.context == context
                })[0]
                if let image = CommonDao.s.getThumbnailImage(context: context) {
                    targetThumbnail.subviews.forEach({ (v) in
                        if NSStringFromClass(type(of: v)) == "NVActivityIndicatorView.NVActivityIndicatorView" {
                            let indicator = v as! NVActivityIndicatorView
                            indicator.stopAnimating()
                            indicator.alpha = 0
                            indicator.removeFromSuperview()
                        }
                    })
                    targetThumbnail.setImage(nil, for: .normal)
                    targetThumbnail.setBackgroundImage(image, for: .normal)
                } else {
                    log.error("missing thumbnail image")
                }
            }
        }
    }
    
    func footerViewModelDidLoadThumbnail(eachThumbnail: [HistoryItem]) {
        if eachThumbnail.count > 0 {
            eachThumbnail.forEach { (item) in
                let btn = createCaptureSpace(context: item.context, isPrivateMode: item.isPrivate == "true")
                if !item.context.isEmpty {
                    if let image = CommonDao.s.getThumbnailImage(context: item.context) {
                        btn.setImage(nil, for: .normal)
                        btn.setBackgroundImage(image, for: .normal)
                    }
                }
            }
        }
    }

// MARK: Gesture Event
    func longPressed(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            for (index, thumbnail) in self.thumbnails.enumerated() {
                if sender.view == thumbnail {
                    self.viewModel.notifyRemoveWebView(index: index)
                    break
                }
            }
        default:break
        }
    }
    
// MARK: Button Event
    func onTappedThumbnail(_ sender: AnyObject) {
        viewModel.notifyChangeWebView(index: thumbnails.index(of: (sender as! Thumbnail))!)
    }
}
