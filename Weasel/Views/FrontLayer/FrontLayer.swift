//
//  FrontLayer.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol FrontLayerDelegate {
    func frontLayerDidInvalidate()
}

class FrontLayer: UIView, CircleMenuDelegate, OptionMenuTableViewDelegate {
    var delegate: FrontLayerDelegate?
    var swipeDirection: EdgeSwipeDirection = .none
    private var optionMenu: OptionMenuTableView? = nil
    private var overlay: UIButton! = nil
    /// ["20170625": ["123456", "234567"], "20170626": ["123456", "234567"]]の形式
    private var deleteHistoryIds: [String: [String]] = [:]
    private var deleteFavoriteIds: [String] = []
    private var deleteFormIds: [String] = []

    let kCircleButtonRadius = 43;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // バックグラウンドに入るときに保持していた削除対象を削除する
        NotificationCenter.default.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            self!.deleteStoreData()
        }
        
        overlay = UIButton(frame: frame)
        overlay.backgroundColor = UIColor.lightGray
        self.overlay.alpha = 0
        _ = overlay.reactive.tap
            .observe { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                if let optionMenu = self.optionMenu {
                    let window: UIWindow? = {
                        for w in UIApplication.shared.windows {
                            if NSStringFromClass(type(of: w)) == "UIRemoteKeyboardWindow" {
                                return w
                            }
                        }
                        return nil
                    }()
                    if window != nil {
                        optionMenu.closeKeyBoard()
                    } else {
                        self.optionMenuDidClose()
                    }
                }
        }
        addSubview(overlay)
        UIView.animate(withDuration: 0.35) {
            self.overlay.alpha = 0.2
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        let menuItems = [
            [
                CircleMenuItem(tapAction: { [weak self] (initialPt: CGPoint) in
                    // オプションメニューの表示位置を計算
                    let ptX = self!.swipeDirection == .left ? initialPt.x / 6 : DeviceDataManager.shared.displaySize.width - 250  - (DeviceDataManager.shared.displaySize.width - initialPt.x) / 6
                    let ptY: CGFloat = { () -> CGFloat in
                        let y = initialPt.y - AppDataManager.shared.optionMenuSize.height / 2
                        if y < 0 {
                            return 0
                        }
                        if y + AppDataManager.shared.optionMenuSize.height > DeviceDataManager.shared.displaySize.height {
                            return DeviceDataManager.shared.displaySize.height - AppDataManager.shared.optionMenuSize.height
                        }
                        return y
                    }()
                    let viewModel = BaseMenuViewModel()
                    viewModel.setup()
                    self!.optionMenu = OptionMenuTableView(frame: CGRect(x: ptX, y: ptY, width: AppDataManager.shared.optionMenuSize.width, height: AppDataManager.shared.optionMenuSize.height), viewModel: viewModel, direction: self!.swipeDirection)
                    self!.optionMenu?.delegate = self
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self!.addSubview(self!.optionMenu!)
                    }
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("自動スクロール")
                    NotificationCenter.default.post(name: .baseViewModelWillAutoScroll, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("ヒストリーバック")
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryBackWebView, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("ヒストリーフォワード")
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryForwardWebView, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("デリート")
                    NotificationCenter.default.post(name: .baseViewModelWillRemoveWebView, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("アッド")
                    NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
                })
            ],
            [
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                })
            ]
        ]
        let circleMenu = CircleMenu(frame: CGRect(origin: CGPoint(x: -100, y: -100), size: CGSize(width: kCircleButtonRadius, height: kCircleButtonRadius)) ,menuItems: menuItems)
        circleMenu.swipeDirection = swipeDirection
        circleMenu.delegate = self
        addSubview(circleMenu)
    }
    
// MARK: Private Method
    /// 閲覧履歴、お気に入り、フォームデータを削除する
    func deleteStoreData() {
        // 履歴
        StoreManager.shared.deleteStoreData(deleteHistoryIds: deleteHistoryIds)
        // お気に入り
        let deleteFavorites = deleteFavoriteIds.map { (id) -> Favorite in
            return StoreManager.shared.selectFavorite(id: id)!
        }
        if deleteFavorites.count > 0 {
            StoreManager.shared.deleteWithRLMObjects(data: deleteFavorites)
            NotificationCenter.default.post(name: .baseViewModelWillChangeFavorite, object: nil)
        }
        deleteHistoryIds = [:]
        deleteFavoriteIds = []
        deleteFormIds = []
    }

// MARK: CircleMenuDelegate
    func circleMenuDidClose() {
        if self.optionMenu == nil {
            UIView.animate(withDuration: 0.15, animations: { 
                self.overlay.alpha = 0
            }, completion: { (finished) in
                if finished {
                    self.delegate?.frontLayerDidInvalidate()
                }
            })
        }
    }
    
// MARK: OptionMenuTableViewDelegate
    func optionMenuDidClose() {
        deleteStoreData()
        UIView.animate(withDuration: 0.15, animations: {
            self.overlay.alpha = 0
            self.optionMenu?.alpha = 0
            self.alpha = 0
        }, completion: { (finished) in
            if finished {
                self.optionMenu?.removeFromSuperview()
                self.optionMenu = nil
                self.delegate?.frontLayerDidInvalidate()
            }
        })
    }
    
    func optionMenuDidCloseDetailMenu() {
        deleteStoreData()
    }
    
    func optionMenuDidDeleteHistoryData(_id: String, date: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
        dateFormatter.dateFormat = "yyyyMMdd"
        let key = dateFormatter.string(from: date)
        if deleteHistoryIds[key] == nil {
            deleteHistoryIds[key] = [_id]
        } else {
            deleteHistoryIds[key]?.append(_id)
        }
    }
    
    func optionMenuDidDeleteFavoriteData(_id: String) {
        deleteFavoriteIds.append(_id)
    }
    
    func optionMenuDidDeleteFormData(_id: String) {
        deleteFormIds.append(_id)
    }
}
