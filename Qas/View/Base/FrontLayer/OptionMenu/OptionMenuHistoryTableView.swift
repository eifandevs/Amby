//
//  OptionMenuHistoryTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

import UIKit

protocol OptionMenuHistoryTableViewDelegate: class {
    func optionMenuHistoryDidClose()
}

class OptionMenuHistoryTableView: UIView, ShadowView {
    
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
        
        if #available(iOS 11.0, *) {
            // safe area対応
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        // カスタムビュー登録
        tableView.register(R.nib.optionMenuHistoryTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier)
        
        self.addSubview(view)
    }
}

// MARK: - TableView Delegate
extension OptionMenuHistoryTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuHistoryCell.identifier, for: indexPath) as! OptionMenuHistoryTableViewCell

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
}

extension OptionMenuHistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.debug("select")
    }
}

