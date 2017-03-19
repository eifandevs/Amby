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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(thumbnailSize: CGSize) {
        self.init(frame: CGRect.zero)
        imageSize = thumbnailSize

        backgroundColor = UIColor.white
        scrollView.backgroundColor = UIColor.frenchBlue
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = true
        addSubview(scrollView)
        
        let btn = UIButton(frame: CGRect(origin: CGPoint.zero, size: imageSize))
        btn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        scrollView.addSubview(btn)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
    }
}
