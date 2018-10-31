//
//  OptionMenuFavoriteTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class OptionMenuFavoriteTableView: UIView, ShadowView, OptionMenuView {
    // メニュークローズ通知用RX
    let rx_optionMenuFavoriteDidClose = PublishSubject<()>()

    let viewModel = OptionMenuFavoriteTableViewModel()
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
        guard let view = Bundle.main.loadNibNamed(R.nib.optionMenuFavoriteTableView.name, owner: self, options: nil)?.first as? UIView else {
            return
        }

        view.frame = bounds

        // 影
        addMenuShadow()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // OptionMenuProtocol
        _ = setup(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuFavoriteTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuFavoriteCell.identifier)

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
                            self.viewModel.removeRow(indexPath: indexPath, row: row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)

                            self.tableView.endUpdates()
                        }
                    }
                }
                log.eventOut(chain: "rx_longPress")
            }
            .disposed(by: rx.disposeBag)

        addGestureRecognizer(longPressRecognizer)
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
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セル情報取得
        let row = viewModel.getRow(indexPath: indexPath)
        // ページを表示
        viewModel.loadRequest(url: row.data.url)
        // 通知
        rx_optionMenuFavoriteDidClose.onNext(())
    }
}
