//
//  OptionMenuCooperationTableView.swift
//  Amby
//
//  Created by tenma on 2018/11/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

enum OptionMenuTabGroupTableViewAction {
    case close
}

class OptionMenuTabGroupTableView: UIView, ShadowView, OptionMenuView {
    // アクション通知用RX
    let rx_action = PublishSubject<OptionMenuTabGroupTableViewAction>()

    private let refreshControl = UIRefreshControl()

    private let viewModel = OptionMenuTabGroupTableViewModel()
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
        tableView.register(R.nib.optionMenuTabGroupTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuTabGroupCell.identifier)

        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(0)
            make.right.equalTo(snp.right).offset(0)
            make.top.equalTo(snp.top).offset(0)
            make.bottom.equalTo(snp.bottom).offset(0)
        }

        setupRx()
    }

    func setupRx() {
        // pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: MessageConst.OPTION_MENU.TAB_GROUP_REFRESH_TEXT)
        refreshControl.tintColor = UIColor.darkGray
        tableView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                DispatchQueue.mainSyncSafe {
                    self.refreshControl.endRefreshing()
                    self.viewModel.addGroup()
                }
            })
            .disposed(by: rx.disposeBag)

        // リロード監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .reload = action else { return }
                self.tableView.reloadData()
            }
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuTabGroupTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.reuseIdentifier.optionMenuTabGroupCell.identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuTabGroupTableViewCell {
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

extension OptionMenuTabGroupTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.changeGroup(indexPath: indexPath)
        rx_action.onNext(.close)
    }

    @available(iOS 11.0, *)
    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: AppConst.OPTION_MENU.DELETE, handler: { _, _, completion in
            if self.viewModel.cellCount > 1 {
                self.tableView.beginUpdates()
                self.viewModel.removeRow(indexPath: indexPath)
                self.tableView.deleteRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
                completion(true)
            } else {
                self.viewModel.removeRow(indexPath: indexPath)
                completion(false)
            }
        })

        let editButton = UIContextualAction(style: UIContextualAction.Style.destructive, title: AppConst.OPTION_MENU.EDIT, handler: { _, _, completion in
            self.viewModel.changeGroupTitle(indexPath: indexPath)
            completion(false)
        })
        editButton.backgroundColor = UIColor.lightGreen

        let row = viewModel.getRow(indexPath: indexPath)
        let title = row.isPrivate ? AppConst.OPTION_MENU.UNLOCK : AppConst.OPTION_MENU.LOCK
        let lockButton = UIContextualAction(style: UIContextualAction.Style.destructive, title: title, handler: { _, _, completion in
            self.viewModel.invertPrivateMode(indexPath: indexPath)
            completion(false)
        })
        lockButton.backgroundColor = UIColor.purple

        let config = UISwipeActionsConfiguration(actions: [deleteAction, editButton, lockButton])
        config.performsFirstActionWithFullSwipe = false

        return config
    }
}
