//
//  OptionMenuHistoryTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

protocol OptionMenuHistoryTableViewDelegate: class {
    func optionMenuHistoryDidClose(view: UIView)
}

class OptionMenuHistoryTableView: UIView, ShadowView, OptionMenuView {
    
    let viewModel = OptionMenuHistoryTableViewModel()
    weak var delegate: OptionMenuHistoryTableViewDelegate?
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
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuHistoryTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        
        // 影
        addMenuShadow()
        
        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self
        
        // ビューモデル通知
        viewModel.delegate = self
        
        // OptionMenuProtocol
        _ = setup(tableView: tableView)
        
        // カスタムビュー登録
        tableView.register(R.nib.optionMenuHistoryTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier)
        
        self.addSubview(view)

        // ロングプレスで削除
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed
            ))
        addGestureRecognizer(longPressRecognizer)

        // モデルデータ取得
        viewModel.getModelData()
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
                let rowExist = viewModel.removeRow(indexPath: indexPath)
                tableView.deleteRows(at: [indexPath], with: .automatic)

                // モデルから削除
                CommonHistoryDataModel.s.delete(historyIds: [viewModel.getSection(section: indexPath.section).dateString: [row.data._id]])

                if !rowExist {
                    viewModel.removeSection(section: indexPath.section)
                    tableView.deleteSections([indexPath.section], with: .automatic)
                }

                tableView.endUpdates()
            }
        default:
            break
        }
    }

}

// MARK: - TableViewDataSourceDelegate
extension OptionMenuHistoryTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier, for: indexPath) as! OptionMenuHistoryTableViewCell
        let row = viewModel.getRow(indexPath: indexPath)
        cell.setViewModelData(row: row)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : PaddingLabel = PaddingLabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: viewModel.sectionHeight)))
        label.backgroundColor = UIColor.black
        label.textAlignment = .left
        label.text = viewModel.getSection(section: section).dateString
        label.textColor = UIColor.white
        label.font = UIFont(name: AppConst.APP_FONT, size: viewModel.sectionFontSize)
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.sectionHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount(section: section)
    }
}

// MARK: - TableViewDelegate
extension OptionMenuHistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セル情報取得
        let row = viewModel.getRow(indexPath: indexPath)
        // ページを表示
        OperationDataModel.s.executeOperation(operation: .search, object: row.data.url)
        delegate?.optionMenuHistoryDidClose(view: self)
    }
}

// MARK: - OptionMenuHistoryTableViewModelDelegate
extension OptionMenuHistoryTableView: OptionMenuHistoryTableViewModelDelegate {
    func optionMenuHistoryTableViewModelDidGetDataSuccessfull() {
        tableView.reloadData()
    }
}

// MARK: - ScrollViewDelegate
extension OptionMenuHistoryTableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //一番下までスクロールしたかどうか
        if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) {
            viewModel.getModelData()
        }
    }
}

