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

class FooterView: UIView, FooterViewModelDelegate {
    
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
        
        backgroundColor = UIColor.white
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

    func addCaptureSpace() {
        let btn = UIButton()
        btn.center = CGPoint(x: (frame.size.width / 2) + (CGFloat(thumbnails.count) * AppDataManager.shared.thumbnailSize.width), y: frame.size.height / 2)
        btn.bounds.size = AppDataManager.shared.thumbnailSize
        btn.backgroundColor = UIColor.lightGray
        scrollView.addSubview(btn)
        thumbnails.append(btn)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: FooterViewModel Delegate

    func footerViewModelDidAddThumbnail() {
        // 新しいサムネイルスペースを作成
        addCaptureSpace()
    }
    
    func footerViewModelDidStartLoading(index: Int) {
        // くるくるを表示する
        let rect = CGRect(x: 0, y: 0, width: AppDataManager.shared.thumbnailSize.height * 0.7, height: AppDataManager.shared.thumbnailSize.height * 0.7)
        let indicator = NVActivityIndicatorView(frame: rect, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.frenchBlue, padding: 0)
        indicator.center = CGPoint(x: thumbnail.bounds.size.width / 2, y: thumbnail.bounds.size.height / 2)
        thumbnail.addSubview(indicator)
        indicator.startAnimating()
    }
    
}
