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
    
    private var thumbnail: UIButton {
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
        btn.center = CGPoint(x: (frame.size.width / 2) + (CGFloat(thumbnails.count) * AppDataManager.shared.thumbnailSize.width), y: frame.size.height / 2)
        btn.bounds.size = AppDataManager.shared.thumbnailSize
        btn.backgroundColor = UIColor.black
        scrollView.addSubview(btn)
        thumbnails.append(btn)
        return btn
    }
    
    private func startIndicator() {
        // くるくるを表示する
        let rect = CGRect(x: 0, y: 0, width: AppDataManager.shared.thumbnailSize.height * 0.7, height: AppDataManager.shared.thumbnailSize.height * 0.7)
        let indicator = NVActivityIndicatorView(frame: rect, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.frenchBlue, padding: 0)
        indicator.center = CGPoint(x: thumbnail.bounds.size.width / 2, y: thumbnail.bounds.size.height / 2)
        thumbnail.addSubview(indicator)
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
    
    func footerViewModelDidEndLoading(context: String) {
        // くるくるを止めて、サムネイルを表示する
        DispatchQueue.mainSyncSafe { [weak self] _ in
            let image = UIImage(contentsOfFile: AppDataManager.shared.thumbnailPath(folder: context).path)
            if image == nil {
                log.error("missing thumbnail image")
                return
            }
            _ = self!.thumbnail.subviews.map { (v) -> Void in
                v.removeFromSuperview()
            }
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(origin: CGPoint.zero, size: self!.thumbnail.bounds.size)
            self!.thumbnail.addSubview(imageView)
        }
    }
    
    func footerViewModelDidLoadThumbnail(eachThumbnail: [EachHistoryItem]) {
        if eachThumbnail.count > 0 {
            eachThumbnail.forEach { (item) in
                if !item.context.isEmpty {
                    let btn = createCaptureSpace()
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
        } else {
            let _ = createCaptureSpace()
        }
    }
    
}
