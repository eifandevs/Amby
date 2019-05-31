//
//  OptionMenuSettingTableViewCell.swift
//  Amby
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class OptionMenuSettingTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /// ビューモデルデータ反映
    func setRow(row: OptionMenuSettingTableViewModel.Section.Row) {
        titleLabel.text = row.cellType.title
    }
}
