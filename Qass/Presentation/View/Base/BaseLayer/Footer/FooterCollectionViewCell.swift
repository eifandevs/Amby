//
//  FooterCollectionViewCell.swift
//  Qass
//
//  Created by tenma on 2018/11/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class FooterCollectionViewCell: UICollectionViewCell {
    private var row: FooterViewModel.Row!
    private var indicator: NVActivityIndicatorView!
    @IBOutlet var frontBar: UIView!

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

        // フロントバー表示
        if row.isFront {
            frontBar.alpha = 1
        } else {
            frontBar.alpha = 0
        }
    }
}
