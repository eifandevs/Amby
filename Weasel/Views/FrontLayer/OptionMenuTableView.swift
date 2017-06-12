//
//  OptionMenuTableView.swift
//  Weasel
//
//  Created by User on 2017/06/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class OptionMenuTableView: UIView, UITableViewDelegate, UITableViewDataSource, ShadowView {
    
    private var tableView: UITableView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addMenuShadow()
        
        let tableView = UITableView(frame: frame)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.isUserInteractionEnabled = true
        tableView.separatorColor = UIColor.dandilionSeeds
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.showsHorizontalScrollIndicator = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.blind
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.warning("did select")
    }
}
