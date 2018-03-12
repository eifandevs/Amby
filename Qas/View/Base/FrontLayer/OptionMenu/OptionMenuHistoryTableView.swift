//
//  OptionMenuHistoryTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class OptionMenuHistoryTableView: UIView, ShadowView, OptionMenuView {
    
    // メニュークローズ通知用RX
    let rx_optionMenuHistoryDidClose = PublishSubject<Void>()
    
    let viewModel = OptionMenuHistoryTableViewModel()
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
        rx_optionMenuHistoryDidClose.onNext(())
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

