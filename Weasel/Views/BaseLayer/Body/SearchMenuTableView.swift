//
//  SearchMenuTableView.swift
//  Weasel
//
//  Created by temma on 2017/07/18.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol SearchMenuTableViewDelegate {
    func searchMenuDidEndEditing()
}

class SearchMenuTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    var delegate: SearchMenuTableViewDelegate? = nil
    let cellHeight = 50.0
    private var tableView: UITableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        
        backgroundColor = UIColor.white
        
        tableView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.isUserInteractionEnabled = true
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getModelData() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight.cgfloat
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "ああああ"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "aaaaaa"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: 11)))
        label.backgroundColor = UIColor.pastelLightGray
        label.text = "   bbbbbb"
        label.font = UIFont(name: AppConst.appFont, size: 13)
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.warning("tableView.isFirstResponder: \(tableView.isFirstResponder)")
        if !tableView.isFirstResponder {
            delegate?.searchMenuDidEndEditing()
        }
        log.warning("検索を実行")
    }
}
