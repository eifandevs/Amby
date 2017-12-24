//
//  OptionMenuFavoriteTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

protocol OptionMenuFavoriteTableViewDelegate: class {
    func optionMenuFavoriteDidClose(view: UIView)
}

class OptionMenuFavoriteTableView: UIView, ShadowView, OptionMenuView {

    let viewModel = OptionMenuFavoriteTableViewModel()
    weak var delegate: OptionMenuFavoriteTableViewDelegate?
    @IBOutlet weak var tableView: UITableView!

    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func loadNib() {
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuFavoriteTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds

        // 影
        addMenuShadow()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // OptionMenuProtocol
        _ = setup(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuFavoriteTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuFavoriteCell.identifier)

        self.addSubview(view)

        // ロングプレスで削除
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed
            ))
        addGestureRecognizer(longPressRecognizer)
    }

    // MARK: Gesture Event
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            let point: CGPoint = sender.location(in: tableView)
            let indexPath: IndexPath? = tableView.indexPathForRow(at: point)
            if let indexPath = indexPath {
                let row = viewModel.getRow(indexPath: indexPath)

                tableView.beginUpdates()
                viewModel.removeRow(indexPath: indexPath, row: row)
                tableView.deleteRows(at: [indexPath], with: .automatic)

                tableView.endUpdates()
            }
        default:
            break
        }
    }

}

// MARK: - TableViewDataSourceDelegate
extension OptionMenuFavoriteTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuFavoriteCell.identifier, for: indexPath) as! OptionMenuFavoriteTableViewCell
        let row = viewModel.getRow(indexPath: indexPath)
        cell.setViewModelData(row: row)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
}

// MARK: - TableViewDelegate
extension OptionMenuFavoriteTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セル情報取得
        let row = viewModel.getRow(indexPath: indexPath)
        // ページを表示
        OperationDataModel.s.executeOperation(operation: .search, object: row.data.url)
        delegate?.optionMenuFavoriteDidClose(view: self)
    }
}
