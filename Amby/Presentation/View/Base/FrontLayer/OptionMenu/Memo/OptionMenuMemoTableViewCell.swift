//
//  OptionMenuMemoTableViewCell.swift
//  Amby
//
//  Created by tenma on 2018/10/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

protocol OptionMenuMemoTableViewCellDelegate: class {
    func optionMenuMemoTableViewCellDidInvertLock(row: OptionMenuMemoTableViewModel.Row)
}

class OptionMenuMemoTableViewCell: UITableViewCell {
    /// ページ追加通知用RX
    weak var delegate: OptionMenuMemoTableViewCellDelegate?

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var lockImageView: UIImageView!
    @IBOutlet var lockButton: UIButton!

    var row: OptionMenuMemoTableViewModel.Row!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupRx()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupRx() {
        lockButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.optionMenuMemoTableViewCellDidInvertLock(row: self.row)
            })
            .disposed(by: rx.disposeBag)
    }

    func setRow(row: OptionMenuMemoTableViewModel.Row) {
        self.row = row
        titleLabel.text = row.data.text
        lockImageView.isHidden = !row.data.isLocked
        let title = row.data.isLocked ? AppConst.OPTION_MENU.LOCK : AppConst.OPTION_MENU.UNLOCK
        lockButton.setTitle(title, for: .normal)
    }
}
