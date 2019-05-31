//
//  Thumbnail.swift
//  Amby
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

    private let underLine = UIView()

    private let frontBar = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // フロントバーを配置
        frontBar.frame = CGRect(origin: CGPoint(x: 0, y: frame.size.height - 4), size: CGSize(width: frame.size.width, height: 4))
        frontBar.backgroundColor = UIColor.ultraViolet
        frontBar.alpha = 0
        addSubview(frontBar)

        // サムネイルタイトル配置
        thumbnailInfo.titleLabel?.font = UIFont(name: AppConst.APP.FONT, size: frame.size.width / 9)
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
//            privateIcon.setImage(image: R.image.footer_private(), color: UIColor.ultraOrange)
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

        // アンダーライン初期化
        // ライン初期化
        underLine.frame = CGRect(x: -5, y: (frame.size.width / 3) - 1, width: width + 18, height: 1)
        underLine.backgroundColor = UIColor.ultraViolet
        thumbnailInfo.addSubview(underLine)

        // 回転
        let angle: CGFloat = CGFloat((-45.0 * Double.pi) / 180.0)
        thumbnailInfo.transform = CGAffineTransform(rotationAngle: angle)
    }

    // タイトル表示
    func displayTitle() {
        // アンダーラインを横幅を保持しておく
        let width = underLine.frame.size.width
        underLine.frame.size.width = 0

        UIView.animate(withDuration: 0.2, animations: {
            self.thumbnailInfo.alpha = 1
        })

        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.underLine.frame.size.width = width
        }, completion: nil)
    }

    // タイトル非表示
    func undisplayTitle() {
        UIView.animate(withDuration: 0.2, animations: {
            self.thumbnailInfo.alpha = 0
        })
    }

    func float() {
        transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
