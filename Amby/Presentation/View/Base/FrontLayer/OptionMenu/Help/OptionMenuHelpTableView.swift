//
//  OptionMenuHelpTableView.swift
//  Amby
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class OptionMenuHelpTableView: UIView, ShadowView, OptionMenuView {
    private let viewModel = OptionMenuHelpTableViewModel()
    private let tableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    deinit {
        log.debug("deinit called.")
    }

    func setup() {
        // 影
        addMenuShadow()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // OptionMenuProtocol
        _ = setupLayout(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuHelpTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuHelpCell.identifier)

        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(0)
            make.right.equalTo(snp.right).offset(0)
            make.top.equalTo(snp.top).offset(0)
            make.bottom.equalTo(snp.bottom).offset(0)
        }
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuHelpTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.reuseIdentifier.optionMenuHelpCell.identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuHelpTableViewCell {
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

extension OptionMenuHelpTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.getRow(indexPath: indexPath)
        viewModel.openHelpScreen(title: row.subTitle, message: row.message)
    }
}
