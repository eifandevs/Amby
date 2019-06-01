//
//  OptionMenuHelpTableViewCell.swift
//  Amby
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuHelpTableViewCell: UITableViewCell {
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
    func setRow(row: OptionMenuHelpTableViewModel.Row) {
        titleLabel.text = row.title
    }
}
