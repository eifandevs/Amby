//
//  OptionMenuMemoTableView.swift
//  Qass
//
//  Created by tenma on 2018/10/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class OptionMenuMemoTableView: UIView, ShadowView, OptionMenuView {
    @IBOutlet var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private let viewModel = OptionMenuMemoTableViewModel()
    private var defaultContentOffset = CGPoint.zero

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
        if let view = Bundle.main.loadNibNamed(R.nib.optionMenuMemoTableView.name, owner: self, options: nil)?.first as? UIView {
            view.frame = bounds

            // コンテントオフセットが(0, 0)とは限らないので保持しておく
            // pull to refreshしたときにずれたままになる対応
            defaultContentOffset = tableView.contentOffset

            // 影
            addMenuShadow()

            // テーブルビュー監視
            tableView.delegate = self
            tableView.dataSource = self

            // OptionMenuProtocol
            _ = setup(tableView: tableView)

            // カスタムビュー登録
            tableView.register(R.nib.optionMenuMemoTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuMemoCell.identifier)

            setupRx()

            addSubview(view)
        }
    }

    func setupRx() {
        // pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: MessageConst.OPTION_MENU.MEMO_REFRESH_TEXT)
        refreshControl.tintColor = UIColor.ultraViolet
        tableView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_valueChanged")
                guard let `self` = self else { return }
                DispatchQueue.mainSyncSafe {
                    self.tableView.setContentOffset(self.defaultContentOffset, animated: true)
                    self.refreshControl.endRefreshing()
                    self.viewModel.openMemo()
                }
                log.eventOut(chain: "rx_valueChanged")
            })
            .disposed(by: rx.disposeBag)

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
                            self.tableView.beginUpdates()
                            self.viewModel.removeRow(indexPath: indexPath)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)

                            self.tableView.endUpdates()
                        }
                    }
                }
                log.eventOut(chain: "rx_longPress")
            }
            .disposed(by: rx.disposeBag)

        addGestureRecognizer(longPressRecognizer)

        // リロード監視
        viewModel.rx_optionMenuMemoTableViewModelWillReload
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_optionMenuMemoTableViewModelWillReload")
                guard let `self` = self else { return }
                self.tableView.reloadData()
                log.eventOut(chain: "rx_optionMenuMemoTableViewModelWillReload")
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

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellCount
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
