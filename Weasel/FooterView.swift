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
    private let contentView = UIView()
    
    private var frontThumbnail: UIButton {
        get {
            return thumbnails[viewModel.locationIndex]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel.delegate = self
        
        addAreaShadow()
        
        // content
        contentView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width + 1, height: frame.size.height))
        contentView.backgroundColor = UIColor.clear
        
        backgroundColor = UIColor.pastelLightGray
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y:0), size: frame.size)
        scrollView.contentSize = contentView.frame.size
        
        scrollView.bounces = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(contentView)
        
        addSubview(scrollView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Private Method
    
    private func createCaptureSpace() -> UIButton {
        let additionalPointX = ((thumbnails.count).cgfloat * AppDataManager.shared.thumbnailSize.width) - (thumbnails.count - 1 < 0 ? 0 : thumbnails.count - 1).cgfloat * AppDataManager.shared.thumbnailSize.width / 2
        let btn = UIButton(frame: CGRect(origin: CGPoint(x: (frame.size.width / 2) - (AppDataManager.shared.thumbnailSize.width / 2.0) + additionalPointX, y: 0), size: AppDataManager.shared.thumbnailSize))
        btn.backgroundColor = UIColor.black
        _ = btn.reactive.tap
            .observe { _ in
                for (index, thumbnail) in self.thumbnails.enumerated() {
                    if btn == thumbnail {
                        self.viewModel.notifyChangeWebView(index: index)
                        break
                    }
                }
        }
        thumbnails.append(btn)
        
        if ((thumbnails.count).cgfloat * btn.frame.size.width > scrollView.frame.size.width) {
            // スクロールビューのコンテンツサイズを大きくする
            contentView.frame.size.width += btn.frame.size.width / 2
            scrollView.contentSize = contentView.frame.size
            scrollView.contentInset =  UIEdgeInsetsMake(0, scrollView.contentInset.left + (btn.frame.size.width / 2), 0, 0)
        }
        
        contentView.addSubview(btn)

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
    
    private func startIndicator() {
        // くるくるを表示する
        let existIndicator = frontThumbnail.subviews.filter { (view) -> Bool in return view is NVActivityIndicatorView }.count > 0
        if !existIndicator {
            let rect = CGRect(x: 0, y: 0, width: AppDataManager.shared.thumbnailSize.height * 0.7, height: AppDataManager.shared.thumbnailSize.height * 0.7)
            let indicator = NVActivityIndicatorView(frame: rect, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.frenchBlue, padding: 0)
            indicator.center = CGPoint(x: frontThumbnail.bounds.size.width / 2, y: frontThumbnail.bounds.size.height / 2)
            frontThumbnail.addSubview(indicator)
            indicator.startAnimating()
        }
    }
    
// MARK: FooterViewModel Delegate

    func footerViewModelDidAddThumbnail() {
        // 新しいサムネイルスペースを作成
        let _ = createCaptureSpace()
    }
    
    func footerViewModelDidChangeThumbnail() {
        // TODO: 現在値を変更する
    }
    
    func footerViewModelDidRemoveThumbnail(index: Int) {
        let completion: (() -> ()) = { [weak self] _ in
            self!.thumbnails[index].removeFromSuperview()
            self!.thumbnails.remove(at: index)
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
                if ((self.thumbnails.count).cgfloat * AppDataManager.shared.thumbnailSize.width > self.scrollView.frame.size.width) {
                    self.contentView.frame.size.width -= AppDataManager.shared.thumbnailSize.width / 2
                    self.scrollView.contentSize = self.contentView.frame.size
                    self.scrollView.contentInset =  UIEdgeInsetsMake(0, self.scrollView.contentInset.left - (AppDataManager.shared.thumbnailSize.width / 2), 0, 0)
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
