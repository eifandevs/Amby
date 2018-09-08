//
//  SearchMenuSearchHistoryTableViewCell.swift
//  Qas
//
//  Created by tenma on 2018/04/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Model
import UIKit

class SearchMenuSearchHistoryTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    /// 表示内容
    var history: SearchHistory?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setHistory(history: SearchHistory?) {
        self.history = history
        titleLabel.text = history?.title ?? ""
    }
}
