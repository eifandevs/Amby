//
//  OptionMenuHistoryTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

enum OptionMenuHistoryTableViewAction {
    case close
}

class OptionMenuHistoryTableView: UIView, ShadowView, OptionMenuView {
    /// アクション通知用RX
    let rx_action = PublishSubject<OptionMenuHistoryTableViewAction>()

    private let viewModel = OptionMenuHistoryTableViewModel()
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

        // データ更新監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                log.eventIn(chain: "OptionMenuHistoryTableViewModel.rx_action")
                guard let `self` = self, let action = action.element, case .gotData = action else { return }
                self.tableView.reloadData()
                log.eventOut(chain: "OptionMenuHistoryTableViewModel.rx_action")
            }
            .disposed(by: rx.disposeBag)

        // OptionMenuProtocol
        _ = setupLayout(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuHistoryTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier)

        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(0)
            make.right.equalTo(snp.right).offset(0)
            make.top.equalTo(snp.top).offset(0)
            make.bottom.equalTo(snp.bottom).offset(0)
        }

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
                            let row = self.viewModel.getRow(indexPath: indexPath)

                            self.tableView.beginUpdates()
                            let rowExist = self.viewModel.removeRow(indexPath: indexPath, row: row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)

                            if !rowExist {
                                self.viewModel.removeSection(section: indexPath.section)
                                self.tableView.deleteSections([indexPath.section], with: .automatic)
                            }

                            self.tableView.endUpdates()
                        }
                    }
                }
            }
            .disposed(by: rx.disposeBag)

        addGestureRecognizer(longPressRecognizer)

        // モデルデータ取得
        viewModel.getModelData()
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuHistoryTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier, for: indexPath) as? OptionMenuHistoryTableViewCell {
            let row = viewModel.getRow(indexPath: indexPath)
            cell.setRow(row: row)

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: PaddingLabel = PaddingLabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: viewModel.sectionHeight)))
        label.backgroundColor = UIColor.darkGray
        label.textAlignment = .left
        label.text = viewModel.getSection(section: section).dateString
        label.textColor = UIColor.white
        label.font = UIFont(name: AppConst.APP.FONT, size: viewModel.sectionFontSize)
        return label
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return viewModel.sectionHeight
    }

    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount(section: section)
    }
}

// MARK: - TableViewDelegate

extension OptionMenuHistoryTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セル情報取得
        let row = viewModel.getRow(indexPath: indexPath)
        // ページを表示
        viewModel.loadRequest(url: row.data.url)

        rx_action.onNext(.close)
    }
}

// MARK: - ScrollViewDelegate

extension OptionMenuHistoryTableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_: UIScrollView) {
        // 一番下までスクロールしたかどうか
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
            viewModel.getModelData()
        }
    }
}
