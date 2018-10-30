//
//  OptionMenuMemoTableView.swift
//  Qass
//
//  Created by tenma on 2018/10/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OptionMenuMemoTableView: UIView, ShadowView, OptionMenuView {
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
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuMemoTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = bounds

        // 影
        addMenuShadow()

        // テーブルビュー監視
        //        tableView.delegate = self
        //        tableView.dataSource = self
        //
        // OptionMenuProtocol
        _ = setup(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuMemoTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuMemoCell.identifier)

        addSubview(view)
    }
}
