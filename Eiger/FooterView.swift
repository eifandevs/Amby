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
    
    private var viewModel = FooterViewModel(index: UserDefaults.standard.integer(forKey: AppDataManager.shared.locationIndexKey))
    private let scrollView = UIScrollView()
    private var thumbnails: [UIButton] = []
    
    private var frontThumbnail: UIButton {
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
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width + 1, height: scrollView.frame.size.height)
        
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
    
    private func createCaptureSpace() -> UIButton {
        let btn = UIButton(frame: CGRect(origin: CGPoint(x: -100, y: 0), size: AppDataManager.shared.thumbnailSize))
        btn.backgroundColor = UIColor.black
        _ = btn.reactive.tap
            .observe { _ in
                let alert = UIAlertController(title: "アクション", message: "アクションを選択してください", preferredStyle: .actionSheet)
                let delete = UIAlertAction(title: "削除", style: .default, handler: { (action) in
                    for (index, thumbnail) in self.thumbnails.enumerated() {
                        if btn == thumbnail {
                            self.viewModel.notifyRemoveWebView(index: index)
                        }
                    }
                })
                let change = UIAlertAction(title: "変更", style: .default, handler: { (action) in
                    for (index, thumbnail) in self.thumbnails.enumerated() {
                        if btn == thumbnail {
                            self.viewModel.notifyChangeWebView(index: index)
                        }
                    }
                })
                alert.addAction(delete)
                alert.addAction(change)
                Util.shared.foregroundViewController().present(alert, animated: true, completion: nil)
        }
        thumbnails.append(btn)
        scrollView.addSubview(btn)
        return btn
    }
    
    private func startIndicator() {
        // くるくるを表示する
        let rect = CGRect(x: 0, y: 0, width: AppDataManager.shared.thumbnailSize.height * 0.7, height: AppDataManager.shared.thumbnailSize.height * 0.7)
        let indicator = NVActivityIndicatorView(frame: rect, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.frenchBlue, padding: 0)
        indicator.center = CGPoint(x: frontThumbnail.bounds.size.width / 2, y: frontThumbnail.bounds.size.height / 2)
        frontThumbnail.addSubview(indicator)
        indicator.startAnimating()
    }
    
    private func initializeLocation() {
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width + 1, height: scrollView.frame.size.height)
        scrollView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0)
        
        for (index, thumbnail) in thumbnails.enumerated() {
            if (CGFloat(index + 1) * thumbnail.frame.size.width > scrollView.frame.size.width) {
                // スクロールビューのコンテンツサイズを大きくする
                scrollView.contentSize.width += thumbnail.frame.size.width / 2
                scrollView.contentInset =  UIEdgeInsetsMake(0, scrollView.contentInset.left + thumbnail.frame.size.width / 2, 0, 0)
            }
            thumbnail.center = CGPoint(x: (frame.size.width / 2) + (thumbnail.frame.size.width * CGFloat(index)), y: frame.size.height / 2)
            thumbnail.center.x -= (thumbnail.frame.size.width / 2) * CGFloat(thumbnails.count - 1)

        }
        scrollView.scroll(to: .right, animated: false)
    }
    
// MARK: FooterViewModel Delegate

    func footerViewModelDidAddThumbnail() {
        // 新しいサムネイルスペースを作成
        let _ = createCaptureSpace()
        initializeLocation()
    }
    
    func footerViewModelDidChangeThumbnail() {
        // TODO: 現在値を変更する
    }
    
    func footerViewModelDidRemoveThumbnail(index: Int) {
        // フロントではない
        thumbnails[index].removeFromSuperview()
        thumbnails.remove(at: index)
        initializeLocation()
    }
    
    func footerViewModelDidStartLoading(index: Int) {
        startIndicator()
    }
    
    func footerViewModelDidEndLoading(context: String, index: Int) {
        // くるくるを止めて、サムネイルを表示する
        DispatchQueue.mainSyncSafe { [weak self] _ in
            let image = UIImage(contentsOfFile: AppDataManager.shared.thumbnailPath(folder: context).path)
            if image == nil {
                log.error("missing thumbnail image")
                return
            }
            _ = self!.thumbnails[index].subviews.map { (v) -> Void in
                v.removeFromSuperview()
            }
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(origin: CGPoint.zero, size: self!.thumbnails[index].bounds.size)
            self!.thumbnails[index].addSubview(imageView)
        }
    }
    
    func footerViewModelDidLoadThumbnail(eachThumbnail: [EachThumbnailItem]) {
        if eachThumbnail.count > 0 {
            eachThumbnail.forEach { (item) in
                let btn = createCaptureSpace()
                if !item.context.isEmpty {
                    let image = UIImage(contentsOfFile: AppDataManager.shared.thumbnailPath(folder: item.context).path)
                    if image == nil {
                        log.error("missing thumbnail image")
                        return
                    }
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(origin: CGPoint.zero, size: AppDataManager.shared.thumbnailSize)
                    btn.addSubview(imageView)
                }
            }
        }
        self.initializeLocation()
    }
    
}
