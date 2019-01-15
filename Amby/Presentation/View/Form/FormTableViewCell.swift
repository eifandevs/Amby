//
//  FormTableViewCell.swift
//  Amby
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class FormTableViewCell: UITableViewCell {
    @IBOutlet var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setRow(row: FormViewControllerViewModel.Row) {
        valueLabel.text = row.value
    }
}
