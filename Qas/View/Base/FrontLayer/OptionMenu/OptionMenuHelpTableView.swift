//
//  OptionMenuHelpTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class OptionMenuHelpTableView: UIView, ShadowView, OptionMenuView {
    // メニュークローズ通知用RX
    let rx_optionMenuHelpDidClose = PublishSubject<()>()

    let viewModel = OptionMenuHelpTableViewModel()
    @IBOutlet var tableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    deinit {
        log.debug("deinit called.")
    }

    func loadNib() {
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuHelpTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = bounds

        // 影
        addMenuShadow()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // OptionMenuProtocol
        _ = setup(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuHelpTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuHelpCell.identifier)

        addSubview(view)
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuHelpTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuHelpCell.identifier, for: indexPath) as! OptionMenuHelpTableViewCell
        let row = viewModel.getRow(indexPath: indexPath)
        cell.setViewModelData(row: row)

        return cell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellCount
    }
}

// MARK: - TableViewDelegate

extension OptionMenuHelpTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        rx_optionMenuHelpDidClose.onNext(())
        viewModel.executeOperationDataModel(indexPath: indexPath)
    }
}
