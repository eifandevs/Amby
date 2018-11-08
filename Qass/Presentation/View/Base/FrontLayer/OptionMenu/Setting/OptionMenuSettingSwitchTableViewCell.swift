//
//  OptionMenuSettingSwitchTableViewCell.swift
//  Qass
//
//  Created by tenma on 2018/11/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuSettingSwitchTableViewCell: UITableViewCell {
    @IBOutlet var permissionSwitch: UISwitch!

    let viewModel = OptionMenuSettingSwitchTableViewCellViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        permissionSwitch.isOn = viewModel.newWindowConfirm
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func valueChanged(_: Any) {
        viewModel.changeValue(value: permissionSwitch.isOn)
    }
}
