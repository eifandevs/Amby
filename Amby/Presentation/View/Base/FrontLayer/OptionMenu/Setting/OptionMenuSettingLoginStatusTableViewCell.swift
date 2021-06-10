//
//  OptionMenuSettingLoginStatusTableViewCell.swift
//  Amby
//
//  Created by tenma.i on 2019/11/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuSettingLoginStatusTableViewCell: UITableViewCell {
    @IBOutlet var loginStatusLabel: UILabel!

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
        loginStatusLabel.text = row.cellType.title
    }
}
