//
//  OptionMenuSettingSliderTableViewCell.swift
//  Amby
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Model
import UIKit

class OptionMenuSettingSliderTableViewCell: UITableViewCell {
    @IBOutlet var slider: UISlider!

    let viewModel = OptionMenuSettingSliderTableViewCellViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slider.value = Float(-(ScrollUseCase.s.autoScrollInterval))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func valueChanged(_: Any) {
        viewModel.changeValue(value: slider.value)
    }
}
