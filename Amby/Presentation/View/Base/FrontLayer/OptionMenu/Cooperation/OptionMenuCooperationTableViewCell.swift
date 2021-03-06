//
//  OptionMenuCooperationTableViewCell.swift
//  Amby
//
//  Created by tenma on 2018/11/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuCooperationTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setRow(row: OptionMenuCooperationTableViewModel.Row) {
        titleLabel.text = row.title
    }
}
