//
//  OptionMenuView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol OptionMenuView {
    func setupLayout(tableView: UITableView) -> UITableView
}

extension OptionMenuView where Self: UIView {
    func setupLayout(tableView: UITableView) -> UITableView {
        tableView.isUserInteractionEnabled = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 2.5

        if #available(iOS 11.0, *) {
            // safe area対応
            tableView.contentInsetAdjustmentBehavior = .never
        }

        return tableView
    }
}
