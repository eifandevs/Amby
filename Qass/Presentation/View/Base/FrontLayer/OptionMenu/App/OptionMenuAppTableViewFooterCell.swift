//
//  OptionMenuAppTableViewFooterCell.swift
//  Qass
//
//  Created by tenma on 2018/09/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuAppTableViewFooterCell: UITableViewCell {
    @IBOutlet var versionNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        versionNumberLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
