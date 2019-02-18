//
//  OptionMenuFavoriteTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

enum OptionMenuFavoriteTableViewAction {
    case close
}

class OptionMenuFavoriteTableView: UIView, ShadowView, OptionMenuView {
    // メニュークローズ通知用RX
    let rx_action = PublishSubject<OptionMenuFavoriteTableViewAction>()

    private let viewModel = OptionMenuFavoriteTableViewModel()
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
        tableView.register(R.nib.optionMenuFavoriteTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuFavoriteCell.identifier)

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

extension OptionMenuFavoriteTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.reuseIdentifier.optionMenuFavoriteCell.identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuFavoriteTableViewCell {
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

extension OptionMenuFavoriteTableView: UITableViewDelegate {
    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (_, _) -> Void in
            self.tableView.beginUpdates()
            self.viewModel.removeRow(indexPath: indexPath)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
        deleteButton.backgroundColor = UIColor.red

        return [deleteButton]
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セル情報取得
        let row = viewModel.getRow(indexPath: indexPath)
        // ページを表示
        viewModel.loadRequest(url: row.data.url)
        // 通知
        rx_action.onNext(.close)
    }
}
