//
//  OptionMenuHistoryTableViewCell.swift
//  Amby
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuHistoryTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var urlLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /// ビューモデルデータ設定
    func setRow(row: OptionMenuHistoryTableViewModel.Section.Row) {
        titleLabel.text = row.data.title
        urlLabel.text = row.data.url
    }
}
