//
//  OpenSourceTableViewCell.swift
//  Amby
//
//  Created by tenma on 2018/09/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OpenSourceTableViewCell: UITableViewCell {
    @IBOutlet var licenseLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setRow(row: OpenSourceViewControllerViewModel.Row) {
        descriptionLabel.isHidden = !row.expanded
        licenseLabel.text = row.title
        descriptionLabel.text = row.description
    }
}
