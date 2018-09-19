//
//  OpenSourceTableViewCell.swift
//  Qass
//
//  Created by tenma on 2018/09/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OpenSourceTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setTitle(title: String, description: String) {
        titleLabel.text = title
        textView.text = description
    }

    func tapped() {
        textView.isHidden = !textView.isHidden
    }
}
