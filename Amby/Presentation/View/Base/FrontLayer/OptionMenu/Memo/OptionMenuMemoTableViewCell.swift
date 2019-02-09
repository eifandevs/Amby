//
//  OptionMenuMemoTableViewCell.swift
//  Amby
//
//  Created by tenma on 2018/10/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuMemoTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var lockImageView: UIImageView!

    var row: OptionMenuMemoTableViewModel.Row!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setRow(row: OptionMenuMemoTableViewModel.Row) {
        self.row = row
        titleLabel.text = row.data.text
        lockImageView.isHidden = !row.data.isLocked
    }
}
