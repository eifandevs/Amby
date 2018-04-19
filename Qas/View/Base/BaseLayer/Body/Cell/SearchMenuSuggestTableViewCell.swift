//
//  SearchMenuSuggestTableViewCell.swift
//  Qas
//
//  Created by tenma on 2018/04/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class SearchMenuSuggestTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    /// 表示内容
    var suggest: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setSuggest(suggest: String?) {
        self.suggest = suggest

        titleLabel.text = suggest ?? ""
    }
}
