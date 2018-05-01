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

    private let thumbnailInfo = UIButton()

    private let frontBar = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // フロントバーを配置
        frontBar.frame = CGRect(origin: CGPoint(x: 0, y: frame.size.height - 4), size: CGSize(width: frame.size.width, height: 4))
        frontBar.backgroundColor = UIColor.brilliantBlue
        frontBar.alpha = 0
        addSubview(frontBar)

        // サムネイルタイトル配置
        thumbnailInfo.titleLabel?.font = UIFont(name: AppConst.APP_FONT, size: frame.size.width / 9)
        thumbnailInfo.setTitleColor(UIColor.darkGray, for: .normal)
        thumbnailInfo.titleLabel?.lineBreakMode = .byTruncatingTail
        thumbnailInfo.layer.anchorPoint = CGPoint.zero
        thumbnailInfo.alpha = 0
        addSubview(thumbnailInfo)
    }

//    convenience init(frame: CGRect) {
//        self.init(frame: frame)
    // プライベートモードの削除
//        if isPrivateMode {
//            let privateIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width / 4.5, height: frame.size.height / 2))
//            privateIcon.contentMode = .scaleAspectFit
//            privateIcon.setImage(image: R.image.footer_private(), color: UIColor.brilliantBlue)
//            addSubview(privateIcon)
//        }
//    }

    deinit {
        log.debug("deinit called.")
    }

    // MARK: Public Method

    func setThumbnailTitle(title: String) {
        // タイトル初期化
        thumbnailInfo.transform = CGAffineTransform.identity
        thumbnailInfo.setTitle(title, for: .normal)
        // タイトルの横幅を調整
        var width = (thumbnailInfo.titleLabel?.sizeThatFits(frame.size).width)!
        if width > frame.size.width * 2.2 {
            width = frame.size.width * 2.2
        }
        thumbnailInfo.frame = CGRect(x: frame.size.width / 2, y: -30, width: width, height: frame.size.width / 3)

        // ライン初期化
        let underLine = UIView(frame: CGRect(x: -5, y: thumbnailInfo.frame.size.height - 1, width: thumbnailInfo.frame.size.width + 18, height: 1))
        underLine.backgroundColor = UIColor.brilliantBlue
        thumbnailInfo.addSubview(underLine)

        // 回転
        let angle: CGFloat = CGFloat((-45.0 * Double.pi) / 180.0)
        thumbnailInfo.transform = CGAffineTransform(rotationAngle: angle)
    }

    // タイトル表示
    func displayTitle() {
        thumbnailInfo.alpha = 1
    }

    // タイトル非表示
    func undisplayTitle() {
        thumbnailInfo.alpha = 0
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
