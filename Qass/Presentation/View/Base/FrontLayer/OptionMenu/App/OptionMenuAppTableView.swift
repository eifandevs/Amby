//
//  OptionMenuAppTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class OptionMenuAppTableView: UIView, ShadowView, OptionMenuView {
    // メニュークローズ通知用RX
    let rx_optionMenuAppDidClose = PublishSubject<()>()

    let viewModel = OptionMenuAppTableViewModel()
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
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuAppTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = bounds

        // 影
        addMenuShadow()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // OptionMenuProtocol
        _ = setup(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuAppTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuAppCell.identifier)

        tableView.register(R.nib.optionMenuAppTableViewFooterCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuAppFooterCell.identifier)

        // TableViewのフッターを設定
        if let footerCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuAppFooterCell.identifier) as? OptionMenuAppTableViewFooterCell {
            let footerView: UIView = footerCell.contentView
            tableView.tableFooterView = footerView
        }

        addSubview(view)
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuAppTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.reuseIdentifier.optionMenuAppCell.identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuAppTableViewCell {
            let row = viewModel.getRow(indexPath: indexPath)
            cell.setRow(row: row)

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellCount
    }
}

// MARK: - TableViewDelegate

extension OptionMenuAppTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セル情報取得
        switch viewModel.getRow(indexPath: indexPath).cellType {
        case .opensource:
            viewModel.openLicense()
        case .policy:
            viewModel.openPolicy()
        case .source:
            viewModel.openSource()
        case .report:
            viewModel.openReport()
        case .contact:
            viewModel.openContact()
        }
        rx_optionMenuAppDidClose.onNext(())
    }
}
