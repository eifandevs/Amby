//
//  OptionMenuSettingSliderTableViewCell.swift
//  Qas
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class OptionMenuSettingSliderTableViewCell: UITableViewCell {
    @IBOutlet var slider: UISlider!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slider.value = Float(-(ScrollUseCase.s.autoScrollInterval))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func changedValue(_: Any) {
        ScrollUseCase.s.autoScrollInterval = CGFloat(-(slider.value))
    }
}
