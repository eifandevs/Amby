//
//  OptionMenuFormTableViewCell.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class OptionMenuFormTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var urlLabel: UILabel!
    @IBOutlet var openButton: UIButton!

    let viewModel = OptionMenuFormTableViewCellViewModel()

    /// Observable自動解放
    private let disposeBag = DisposeBag()

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
        openButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.readForm(id: self.viewModel.form.id)
            })
            .disposed(by: disposeBag)
    }

    // ビューモデルデータ設定
    func setRow(row: OptionMenuFormTableViewModel.Row) {
        viewModel.form = row.data
        titleLabel.text = row.data.title
        urlLabel.text = row.data.url
    }
}
