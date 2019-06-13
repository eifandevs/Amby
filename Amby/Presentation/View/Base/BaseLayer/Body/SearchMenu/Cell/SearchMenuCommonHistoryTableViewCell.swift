//
//  SearchMenuCommonHistoryTableViewCell.swift
//  Amby
//
//  Created by tenma on 2018/04/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import UIKit

class SearchMenuCommonHistoryTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var urlLabel: UILabel!

    /// 表示内容
    var history: CommonHistory?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setHistory(history: CommonHistory?) {
        self.history = history
        titleLabel.text = history?.title ?? ""
        urlLabel.text = history?.url ?? ""
    }
}
