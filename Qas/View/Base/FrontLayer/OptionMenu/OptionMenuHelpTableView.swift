//
//  OptionMenuHelpTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

protocol OptionMenuHelpTableViewDelegate: class {
    func optionMenuHelpDidClose(view: UIView)
}

class OptionMenuHelpTableView: UIView, ShadowView, OptionMenuView {
    
    let viewModel = OptionMenuHelpTableViewModel()
    weak var delegate: OptionMenuHelpTableViewDelegate?
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
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuHelpTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        
        // 影
        addMenuShadow()
        
        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self
        
        // OptionMenuProtocol
        _ = setup(tableView: tableView)
        
        // カスタムビュー登録
        tableView.register(R.nib.optionMenuHelpTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuHelpCell.identifier)
        
        self.addSubview(view)
    }
    
}

// MARK: - TableViewDataSourceDelegate
extension OptionMenuHelpTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuHelpCell.identifier, for: indexPath) as! OptionMenuHelpTableViewCell
        let row = viewModel.getRow(indexPath: indexPath)
        cell.setViewModelData(row: row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
}

// MARK: - TableViewDelegate
extension OptionMenuHelpTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.optionMenuHelpDidClose(view: self)
        viewModel.executeOperationDataModel(indexPath: indexPath)
    }
}

