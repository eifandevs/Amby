//
//  OptionMenuTableView.swift
//  Weasel
//
//  Created by User on 2017/06/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol OptionMenuTableViewDelegate {
    func optionMenuDidClose()
}

class OptionMenuTableView: UIView, UITableViewDelegate, UITableViewDataSource, ShadowView, OptionMenuTableViewDelegate {
    var delegate: OptionMenuTableViewDelegate? = nil
    private var tableView: UITableView? = nil
    private var detailView: OptionMenuTableView? = nil
    private var viewModel: OptionMenuTableViewModel!
    private var clickedLocation: CGPoint! = nil
    private var swipeDirection: EdgeSwipeDirection! = .none
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addMenuShadow()
        
        backgroundColor = UIColor.clear
        layer.cornerRadius = 2.5
        
        let tableView = UITableView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.isUserInteractionEnabled = true
        tableView.separatorColor = UIColor.dandilionSeeds
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.showsHorizontalScrollIndicator = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 2.5
        addSubview(tableView)
    }
    
    convenience init(frame: CGRect, viewModel: OptionMenuTableViewModel, direction: EdgeSwipeDirection) {
        self.init(frame: frame)
        self.swipeDirection = direction
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuItems.count > 0 ? viewModel.menuItems[section].count : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionItems.count > 0 ? viewModel.sectionItems.count : 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = viewModel.menuItems[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionItems.count > 0 ? viewModel.sectionItems[section] : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if detailView == nil {
            let detailViewModel = viewModel.actionItems[indexPath.row]()
            detailViewModel?.setup()
            if detailViewModel != nil {
                let marginX = swipeDirection == .left ? 30 : -30
                let marginY = 20
                detailView = OptionMenuTableView(frame: frame, viewModel: detailViewModel!, direction: swipeDirection)
                detailView?.center += CGPoint(x: marginX.cgfloat, y: marginY.cgfloat)
                
                if (detailView?.frame.origin.y)! + AppDataManager.shared.optionMenuSize.height > DeviceDataManager.shared.displaySize.height {
                    detailView?.frame.origin.y = DeviceDataManager.shared.displaySize.height - AppDataManager.shared.optionMenuSize.height
                }
                
                detailView?.delegate = self
                superview!.addSubview(detailView!)
            } else {
                // メニューを全て閉じる
                delegate?.optionMenuDidClose()
            }
        } else {
            // オプションメニューとオプションディテールメニューが表示されている状態で、背面のオプションメニューをタップした際のルート
            detailView?.removeFromSuperview()
            detailView = nil
        }
    }
    
// MARK: OptionMenuTableViewDelegate
    func optionMenuDidClose() {
        delegate?.optionMenuDidClose()
    }
}
