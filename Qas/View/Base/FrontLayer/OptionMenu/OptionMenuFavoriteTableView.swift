//
//  OptionMenuFavoriteTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

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
        let longPressRecognizer = UILongPressGestureRecognizer()
        
        longPressRecognizer.rx.event
            .subscribe{ [weak self] sender in
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
            }
            .disposed(by: rx.disposeBag)
        
        addGestureRecognizer(longPressRecognizer)
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
