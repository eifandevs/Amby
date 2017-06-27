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
    func optionMenuDidCloseDetailMenu()
    func optionMenuDidDeleteHistoryData(_id: String, date: Date)
    func optionMenuDidDeleteFavoriteData(_id: String)
    func optionMenuDidDeleteFormData(_id: String)
}

class OptionMenuTableView: UIView, UITableViewDelegate, UITableViewDataSource, ShadowView, OptionMenuTableViewDelegate {
    var delegate: OptionMenuTableViewDelegate? = nil
    private var tableView: UITableView = UITableView()
    private var detailView: OptionMenuTableView? = nil
    private var viewModel: OptionMenuTableViewModel!
    private var swipeDirection: EdgeSwipeDirection = .none
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addMenuShadow()
        
        backgroundColor = UIColor.clear
        layer.cornerRadius = 2.5
        
        tableView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.isUserInteractionEnabled = true
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsHorizontalScrollIndicator = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 2.5
        tableView.register(OptionMenuTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(OptionMenuTableViewCell.self))
        
        // ロングプレスで削除
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed
            ))
        addGestureRecognizer(longPressRecognizer)
        
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
        return viewModel.sectionItems.count > 0 ? viewModel.sectionItems.count : viewModel.menuItems.count > 0 ? 1 : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppDataManager.shared.optionMenuCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OptionMenuTableViewCell.self), for: indexPath) as! OptionMenuTableViewCell
        let menuItem: OptionMenuItem = viewModel.menuItems[indexPath.section][indexPath.row]
        cell.setTitle(menuItem: menuItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionItems.count > 0 ? viewModel.sectionItems[section] : nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = UIColor.pastelLightGray
        label.text = "   \(viewModel.sectionItems[section])"
        label.font = UIFont(name: AppDataManager.shared.appFont, size: 15)
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if detailView == nil {
            let action: ((OptionMenuItem) -> (OptionMenuTableViewModel?))? = { () -> ((OptionMenuItem) -> (OptionMenuTableViewModel?))? in
                if viewModel.commonAction != nil {
                    return viewModel.commonAction!
                }
                if viewModel.menuItems[indexPath.section][indexPath.row].action != nil {
                    return viewModel.menuItems[indexPath.section][indexPath.row].action!
                }
                return nil
            }()
            
            if action != nil {
                let detailViewModel: OptionMenuTableViewModel? = action!((viewModel.menuItems[indexPath.section][indexPath.row]))
                if detailViewModel != nil {
                    detailViewModel!.setup()
                    let marginX = swipeDirection == .left ? 35 : -35
                    let marginY = 20
                    detailView = OptionMenuTableView(frame: frame, viewModel: detailViewModel!, direction: swipeDirection)
                    detailView?.center += CGPoint(x: marginX.cgfloat, y: marginY.cgfloat)
                    
                    if (detailView?.frame.origin.y)! + AppDataManager.shared.optionMenuSize.height > DeviceDataManager.shared.displaySize.height {
                        detailView?.frame.origin.y = DeviceDataManager.shared.displaySize.height - AppDataManager.shared.optionMenuSize.height
                    }
                    
                    detailView?.delegate = self
                    superview!.addSubview(detailView!)
                    
                    let overlay = UIButton(frame: CGRect(origin: CGPoint.zero, size: tableView.frame.size))
                    overlay.backgroundColor = UIColor.clear
                    _ = overlay.reactive.tap
                        .observe { [weak self] _ in
                            guard let `self` = self else {
                                return
                            }
                            // オプションメニューとオプションディテールメニューが表示されている状態で、背面のオプションメニューをタップした際のルート
                            overlay.removeFromSuperview()
                            UIView.animate(withDuration: 0.15, animations: {
                                self.detailView?.alpha = 0
                            }, completion: { (finished) in
                                if finished {
                                    self.detailView?.removeFromSuperview()
                                    self.detailView = nil
                                    self.delegate?.optionMenuDidCloseDetailMenu()
                                }
                            })
                    }
                    tableView.addSubview(overlay)
                } else {
                    // メニューを全て閉じる
                    delegate?.optionMenuDidClose()
                }
            }
        }
    }

// MARK: Gesture Event
    func longPressed(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            let point: CGPoint = sender.location(in: tableView)
            let indexPath: IndexPath? = tableView.indexPathForRow(at: point)
            if let indexPath = indexPath {
                let menuItem = viewModel.menuItems[indexPath.section][indexPath.row]
                if menuItem.type == .deletablePlain {
                    tableView.beginUpdates()
                    viewModel.menuItems[indexPath.section].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    if viewModel.sectionItems.count > 0 && viewModel.menuItems[indexPath.section].count == 0 {
                        viewModel.deleteSection(index: indexPath.section)
                        tableView.deleteSections([indexPath.section], with: .automatic)
                    }
                    // 削除対象をFrontLayerに通知する
                    // データの削除はフロントビューが閉じられた、もしくはBG遷移時に行う
                    if viewModel is HistoryMenuViewModel {
                        delegate?.optionMenuDidDeleteHistoryData(_id: menuItem._id!, date: menuItem.date!)
                    } else if viewModel is FavoriteMenuViewModel {
                        delegate?.optionMenuDidDeleteFavoriteData(_id: menuItem._id!)
                    } else if viewModel is FormMenuViewModel {
                        delegate?.optionMenuDidDeleteFormData(_id: menuItem._id!)
                    }
                    tableView.endUpdates()
                }
            }
        default:
            break
        }
    }
    
// MARK: OptionMenuTableViewDelegate
    func optionMenuDidClose() {
        delegate?.optionMenuDidClose()
    }
    
    func optionMenuDidCloseDetailMenu() {
        delegate?.optionMenuDidCloseDetailMenu()
    }

    func optionMenuDidDeleteHistoryData(_id: String, date: Date) {
        delegate?.optionMenuDidDeleteHistoryData(_id: _id, date: date)
    }
    
    func optionMenuDidDeleteFavoriteData(_id: String) {
        delegate?.optionMenuDidDeleteFavoriteData(_id: _id)
    }
    
    func optionMenuDidDeleteFormData(_id: String) {
        delegate?.optionMenuDidDeleteFormData(_id: _id)
    }
    
// MARK: Public Method
    func closeKeyBoard() {
        if let detailView = detailView {
            detailView.endEditing(true)
        }
    }
}
