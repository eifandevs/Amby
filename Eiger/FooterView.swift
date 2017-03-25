//
//  FooterView.swift
//  Eiger
//
//  Created by temma on 2017/03/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class FooterView: UIView, FooterViewModelDelegate {
    
    private var viewModel = FooterViewModel(index: UserDefaults.standard.integer(forKey: AppDataManager.shared.locationIndexKey))
    private let scrollView = UIScrollView()
    private var imageSize: CGSize! = nil
    private var thumbnails: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, thumbnailSize: CGSize) {
        self.init(frame: frame)
        viewModel.delegate = self
        imageSize = thumbnailSize

        backgroundColor = UIColor.white
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y:0), size: frame.size)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width + 1, height: scrollView.frame.size.height)

        scrollView.bounces = true
        scrollView.backgroundColor = UIColor.frenchBlue
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
//        let btn = UIButton()
//        btn.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
//        btn.bounds.size = thumbnailSize
//        btn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        scrollView.addSubview(btn)
//        thumbnails.append(btn)
        
//        let addCaptureBtn = UIButton()
//        addCaptureBtn.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
//        addCaptureBtn.bounds.size = thumbnailSize
//        addCaptureBtn.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
//        addCaptureBtn.setTitle("追加", for: .normal)
//        _ = addCaptureBtn.reactive.tap
//            .observe { [weak self] _ in
//                let btn = UIButton()
//                btn.center = CGPoint(x: (self!.frame.size.width / 2) + (CGFloat(self!.thumbnails.count) * self!.imageSize.width), y: self!.frame.size.height / 2)
//                btn.bounds.size = self!.imageSize
//                btn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//                addCaptureBtn.frame.origin.x += self!.imageSize.width
//                self!.scrollView.addSubview(btn)
//                self!.thumbnails.append(btn)
//                
//        }
//        scrollView.addSubview(addCaptureBtn)
    }

    func addCaptureSpace() {
        let btn = UIButton()
        btn.center = CGPoint(x: (frame.size.width / 2) + (CGFloat(thumbnails.count) * imageSize.width), y: frame.size.height / 2)
        btn.bounds.size = imageSize
        btn.backgroundColor = UIColor.gray
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
    }
    
}
