//
//  OptionMenuHistoryTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class OptionMenuHistoryTableView: UIView, ShadowView, OptionMenuView {
    // メニュークローズ通知用RX
    let rx_optionMenuHistoryDidClose = PublishSubject<()>()

    let viewModel = OptionMenuHistoryTableViewModel()
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
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuHistoryTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = bounds

        // 影
        addMenuShadow()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // データ更新監視
        viewModel.rx_optionMenuHistoryTableViewModelDidGetData
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_optionMenuHistoryTableViewModelDidGetData")
                guard let `self` = self else { return }
                self.tableView.reloadData()
                log.eventOut(chain: "rx_optionMenuHistoryTableViewModelDidGetData")
            }
            .disposed(by: rx.disposeBag)

        // OptionMenuProtocol
        _ = setup(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuHistoryTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier)

        addSubview(view)

        // ロングプレスで削除
        let longPressRecognizer = UILongPressGestureRecognizer()

        longPressRecognizer.rx.event
            .subscribe { [weak self] sender in
                log.eventIn(chain: "rx_longPress")
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
                log.eventOut(chain: "rx_longPress")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier, for: indexPath) as! OptionMenuHistoryTableViewCell
        let row = viewModel.getRow(indexPath: indexPath)
        cell.setViewModelData(row: row)

        return cell
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: PaddingLabel = PaddingLabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: viewModel.sectionHeight)))
        label.backgroundColor = UIColor.black
        label.textAlignment = .left
        label.text = viewModel.getSection(section: section).dateString
        label.textColor = UIColor.white
        label.font = UIFont(name: AppConst.APP_FONT, size: viewModel.sectionFontSize)
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
        OperationDataModel.s.executeOperation(operation: .search, object: row.data.url)
        rx_optionMenuHistoryDidClose.onNext(())
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
