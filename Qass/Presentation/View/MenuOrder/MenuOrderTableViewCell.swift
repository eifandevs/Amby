//
//  MenuOrderTableViewCell.swift
//  Qass
//
//  Created by tenma on 2018/10/15.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class MenuOrderTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var orderImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setRow(row: MenuOrderViewControllerViewModel.Row) {
        titleLabel.text = row.operation.title()
    }
}
