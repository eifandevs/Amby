//
//  OptionMenuCooperationTableView.swift
//  Amby
//
//  Created by tenma on 2018/11/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

enum OptionMenuCooperationTableViewAction {
    case close
}

class OptionMenuCooperationTableView: UIView, ShadowView, OptionMenuView {
    // アクション通知用RX
    let rx_action = PublishSubject<OptionMenuCooperationTableViewAction>()

    private let viewModel = OptionMenuCooperationTableViewModel()
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
        tableView.register(R.nib.optionMenuCooperationTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuCooperationCell.identifier)

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

extension OptionMenuCooperationTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.reuseIdentifier.optionMenuCooperationCell.identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuCooperationTableViewCell {
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

extension OptionMenuCooperationTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
//        let row = viewModel.getRow(indexPath: indexPath)
        rx_action.onNext(.close)
    }
}
