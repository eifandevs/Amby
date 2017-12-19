//
//  OptionMenuHistoryTableViewCell.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class OptionMenuHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// ビューモデルデータ設定
    func setViewModelData(row: OptionMenuHistoryTableViewModel.Section.Row) {
        titleLabel.text = row.data.title
        urlLabel.text = row.data.url
    }
}
