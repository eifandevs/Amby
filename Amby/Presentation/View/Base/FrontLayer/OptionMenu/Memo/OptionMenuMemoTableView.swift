//
//  OptionMenuMemoTableView.swift
//  Amby
//
//  Created by tenma on 2018/10/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class OptionMenuMemoTableView: UIView, ShadowView, OptionMenuView {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()

    private let viewModel = OptionMenuMemoTableViewModel()
    private var defaultContentOffset = CGPoint.zero

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
        tableView.register(R.nib.optionMenuMemoTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuMemoCell.identifier)

        setupRx()

        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(0)
            make.right.equalTo(snp.right).offset(0)
            make.top.equalTo(snp.top).offset(0)
            make.bottom.equalTo(snp.bottom).offset(0)
        }

        // コンテントオフセットが(0, 0)とは限らないので保持しておく
        // pull to refreshしたときにずれたままになる対応
        defaultContentOffset = tableView.contentOffset
    }

    func setupRx() {
        // pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: MessageConst.OPTION_MENU.MEMO_REFRESH_TEXT)
        refreshControl.tintColor = UIColor.darkGray
        tableView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                DispatchQueue.mainSyncSafe {
                    self.tableView.setContentOffset(self.defaultContentOffset, animated: true)
                    self.refreshControl.endRefreshing()
                    self.viewModel.openMemo()
                }
            })
            .disposed(by: rx.disposeBag)

        // ロングプレスで削除
        let longPressRecognizer = UILongPressGestureRecognizer()

        longPressRecognizer.rx.event
            .subscribe { [weak self] sender in
                guard let `self` = self else { return }
                if let sender = sender.element {
                    if sender.state == .began {
                        let point: CGPoint = sender.location(in: self.tableView)
                        let indexPath: IndexPath? = self.tableView.indexPathForRow(at: point)
                        if let indexPath = indexPath {
                            self.tableView.beginUpdates()
                            self.viewModel.removeRow(indexPath: indexPath)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)

                            self.tableView.endUpdates()
                        }
                    }
                }
            }
            .disposed(by: rx.disposeBag)

        addGestureRecognizer(longPressRecognizer)

        // リロード監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                log.eventIn(chain: "OptionMenuMemoTableViewModel.rx_action")
                guard let `self` = self, let action = action.element, case .reload = action else { return }
                self.tableView.reloadData()
                log.eventOut(chain: "OptionMenuMemoTableViewModel.rx_action")
            }
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuMemoTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.reuseIdentifier.optionMenuMemoCell.identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuMemoTableViewCell {
            let row = viewModel.getRow(indexPath: indexPath)
            cell.setRow(row: row)
            // 重複呼び出しを考慮し、Rxではなくデリゲートパターン
            cell.delegate = self

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellCount
    }
}

// MARK: - OptionMenuMemoTableViewCellDelegate

extension OptionMenuMemoTableView: OptionMenuMemoTableViewCellDelegate {
    func optionMenuMemoTableViewCellDidInvertLock(row: OptionMenuMemoTableViewModel.Row) {
        viewModel.invertLock(memo: row.data)
    }
}

// MARK: - TableViewDelegate

extension OptionMenuMemoTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セル情報取得
        let row = viewModel.getRow(indexPath: indexPath)
        viewModel.openMemo(memo: row.data)
    }
}
