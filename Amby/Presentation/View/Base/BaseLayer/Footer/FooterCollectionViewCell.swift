//
//  FooterCollectionViewCell.swift
//  Amby
//
//  Created by tenma on 2018/11/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class FooterCollectionViewCell: UICollectionViewCell {
    private var row: FooterViewModel.Row!
    private var indicator: NVActivityIndicatorView!
    private let thumbnailInfo = UIButton()
    private let underLine = UIView()

    @IBOutlet var frontBar: UIView!
    @IBOutlet var thumbnailButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        // インジケータ表示
        indicator = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.ultraViolet, padding: 0)
        indicator.isUserInteractionEnabled = false
        addSubview(indicator!)

        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(snp.height).multipliedBy(0.7)
            make.width.equalTo(snp.width).multipliedBy(0.7)
        }

        // デフォルト背景設定
        thumbnailButton.backgroundColor = UIColor.darkGray
        thumbnailButton.setImage(image: R.image.footerThumbnailBack(), color: UIColor.gray)
        let inset: CGFloat = thumbnailButton.frame.size.width / 9
        thumbnailButton.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

        // サムネイルタイトル配置
        layer.masksToBounds = false
        thumbnailInfo.titleLabel?.font = UIFont(name: AppConst.APP.FONT, size: frame.size.width / 4)
        thumbnailInfo.setTitleColor(UIColor.darkGray, for: .normal)
        thumbnailInfo.titleLabel?.lineBreakMode = .byTruncatingTail
        thumbnailInfo.alpha = 0
        thumbnailInfo.layer.anchorPoint = CGPoint.zero
        addSubview(thumbnailInfo)
    }

    func setRow(row: FooterViewModel.Row) {
        self.row = row

        // インジケータ表示
        if row.isLoading {
            indicator.alpha = 1
            indicator.startAnimating()
        } else {
            indicator.alpha = 0
            indicator.stopAnimating()
        }

        // サムネイル表示
        if let thumbnail = row.thumbnail {
            thumbnailButton.setImage(nil, for: .normal)
            thumbnailButton.setBackgroundImage(thumbnail, for: .normal)
        } else {
            thumbnailButton.setImage(image: R.image.footerThumbnailBack(), color: UIColor.gray)
            thumbnailButton.setBackgroundImage(nil, for: .normal)
        }

        // フロントバー表示
        if row.isFront {
            frontBar.alpha = 1
        } else {
            frontBar.alpha = 0
        }

        // タイトルセットアップ
        setupTitle(title: row.title)

        // タイトル表示
        if row.isDragging {
            displayTitle()
        } else {
            undisplayTitle()
        }
    }

    /// タイトル初期化
    private func setupTitle(title: String) {
        // タイトルの長さに応じて、サイズを変更する
        thumbnailInfo.transform = CGAffineTransform.identity
        thumbnailInfo.alpha = 0
        thumbnailInfo.setTitle(title, for: .normal)
        // タイトルの横幅を調整
        var width = (thumbnailInfo.titleLabel?.sizeThatFits(frame.size).width)!
        if width > frame.size.width * 2 {
            width = frame.size.width * 2
        }
        thumbnailInfo.frame = CGRect(x: frame.size.width / 2.8, y: -30, width: width, height: frame.size.width / 3)

        // アンダーライン初期化
        // ライン初期化
        underLine.frame = CGRect(x: -5, y: (frame.size.width / 3) - 1, width: width + 18, height: 1)
        underLine.backgroundColor = UIColor.ultraViolet
        underLine.alpha = 0
        thumbnailInfo.addSubview(underLine)

        // 回転
        let angle: CGFloat = CGFloat((-45.0 * Double.pi) / 180.0)
        thumbnailInfo.transform = CGAffineTransform(rotationAngle: angle)
    }

    // タイトル表示
    private func displayTitle() {
        if row.title.isEmpty { return }

        // アンダーラインを横幅を保持しておく
        let width = underLine.frame.size.width
        underLine.frame.size.width = 0

        underLine.alpha = 1

        UIView.animate(withDuration: 0.2, animations: {
            self.thumbnailInfo.alpha = 1
        })

        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.underLine.frame.size.width = width
        }, completion: nil)
    }

    // タイトル非表示
    private func undisplayTitle() {
        if row.title.isEmpty { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.thumbnailInfo.alpha = 0
        })
    }
}
