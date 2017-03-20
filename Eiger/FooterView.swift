//
//  FooterView.swift
//  Eiger
//
//  Created by temma on 2017/03/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class FooterView: UIView {
    
    private let scrollView = UIScrollView()
    private var imageSize: CGSize! = nil
    private var thumbnails: [UIButton] = [] {
        didSet {
            log.debug("サムネイルを追加します")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, thumbnailSize: CGSize) {
        self.init(frame: frame)
        imageSize = thumbnailSize

        backgroundColor = UIColor.white
        scrollView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        scrollView.contentSize = frame.size
        scrollView.bounces = true
        scrollView.backgroundColor = UIColor.frenchBlue
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = true
        addSubview(scrollView)
        
        let btn = UIButton()
        btn.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        btn.bounds.size = thumbnailSize
        btn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        scrollView.addSubview(btn)
        thumbnails.append(btn)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
