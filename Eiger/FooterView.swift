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
        let btn = UIButton()
        let animationsCount = thumbnails.count == 0 ? 0 : thumbnails.count - 1
        btn.center = CGPoint(x: (frame.size.width / 2) + (CGFloat(thumbnails.count) * AppDataManager.shared.thumbnailSize.width) - (CGFloat(animationsCount) * AppDataManager.shared.thumbnailSize.width / 2), y: frame.size.height / 2)
        btn.bounds.size = AppDataManager.shared.thumbnailSize
        btn.backgroundColor = UIColor.black
        _ = btn.reactive.tap
            .observe { _ in
                log.warning("削除!!")
        }
        scrollView.addSubview(btn)
        scrollView.backgroundColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
        thumbnails.append(btn)
        if CGFloat(thumbnails.count) * btn.frame.size.width > scrollView.frame.size.width {
            // スクロールビューのコンテンツサイズを大きくする
            scrollView.contentSize.width += btn.frame.size.width / 2
            scrollView.contentInset =  UIEdgeInsetsMake(0, scrollView.contentInset.left + btn.frame.size.width / 2, 0, 0)
        }
        if thumbnails.count > 1 {
            UIView.animate(withDuration: 0.2, animations: {
                self.thumbnails.forEach({ (item) in
                    item.frame.origin.x -= btn.frame.size.width / 2
                })
            }, completion: nil)
        }
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
    
// MARK: FooterViewModel Delegate

    func footerViewModelDidAddThumbnail() {
        // 新しいサムネイルスペースを作成
        let _ = createCaptureSpace()
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
    }
    
}