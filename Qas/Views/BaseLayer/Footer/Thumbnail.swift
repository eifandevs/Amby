//
//  Thumbnail.swift
//  Qas
//
//  Created by temma on 2017/07/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class Thumbnail: UIButton {
    var context: String!
    var isFront = false {
        didSet {
            frontBar.alpha = isFront ? 1 : 0
        }
    }
    var thumbnailInfo: UIButton!

    private let frontBar = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        frontBar.frame = CGRect(origin: CGPoint(x: 0, y: frame.size.height - 4), size: CGSize(width: frame.size.width, height: 4))
        frontBar.backgroundColor = UIColor.brilliantBlue
        frontBar.alpha = 0
        addSubview(frontBar)
        let h = frame.size.width / 3
        let w = frame.size.width * 2.5

        thumbnailInfo = UIButton(frame: CGRect(x: h / 3.6, y: -(w / 2) , width: w, height: h))
        thumbnailInfo.backgroundColor = UIColor.darkGray
        let angle2:CGFloat = CGFloat((-45.0 * Double.pi) / 180.0)
        thumbnailInfo.transform = CGAffineTransform(rotationAngle: angle2)
        thumbnailInfo.titleLabel?.font = UIFont(name: AppConst.appFont, size: h / 3)
        thumbnailInfo.titleLabel?.textColor = UIColor.white
        thumbnailInfo.titleLabel?.lineBreakMode = .byTruncatingTail
        thumbnailInfo.setTitle(" あああああああああああああああああああああああああああああ ", for: .normal)
        thumbnailInfo.alpha = 0
        addSubview(thumbnailInfo)
    }
    
    convenience init(frame: CGRect, isPrivateMode: Bool = false) {
        self.init(frame: frame)
        if isPrivateMode {
            let privateIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width / 4.5, height: frame.size.height / 2))
            privateIcon.contentMode = .scaleAspectFit
            privateIcon.setImage(image: R.image.footer_private(), color: UIColor.brilliantBlue)
            addSubview(privateIcon)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
