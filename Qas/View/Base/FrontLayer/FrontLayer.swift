//
//  FrontLayer.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol FrontLayerDelegate: class {
    func frontLayerDidInvalidate()
}

class FrontLayer: UIView, CircleMenuDelegate, OptionMenuTableViewDelegate {
    weak var delegate: FrontLayerDelegate?
    var swipeDirection: EdgeSwipeDirection = .none
    private var optionMenu: OptionMenuTableView?
    private var overlay: UIButton!
    private var circleMenu: CircleMenu!
    /// ["20170625": ["123456", "234567"], "20170626": ["123456", "234567"]]の形式
    private var deleteHistoryIds: [String: [String]] = [:]
    private var deleteFavoriteIds: [String] = []
    private var deleteFormIds: [String] = []

    let kCircleButtonRadius = 43;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // バックグラウンドに入るときに保持していた削除対象を削除する
        NotificationCenter.default.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            self.deleteStoreData()
        }
        
        overlay = UIButton(frame: frame)
        overlay.backgroundColor = UIColor.darkGray
        self.overlay.alpha = 0
        overlay.addTarget(self, action: #selector(self.onTappedOverlay(_:)), for: .touchUpInside)
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
                CircleMenuItem(image: R.image.circlemenu_menu(), tapAction: { [weak self] (initialPt: CGPoint) in
                    // オプションメニューの表示位置を計算
                    let ptX = self!.swipeDirection == .left ? initialPt.x / 6 : DeviceConst.displaySize.width - 250  - (DeviceConst.displaySize.width - initialPt.x) / 6
                    let ptY: CGFloat = { () -> CGFloat in
                        let y = initialPt.y - AppConst.optionMenuSize.height / 2
                        if y < 0 {
                            return 0
                        }
                        if y + AppConst.optionMenuSize.height > DeviceConst.displaySize.height {
                            return DeviceConst.displaySize.height - AppConst.optionMenuSize.height
                        }
                        return y
                    }()
                    let viewModel = BaseMenuViewModel()
                    viewModel.setup()
                    self!.optionMenu = OptionMenuTableView(frame: CGRect(x: ptX, y: ptY, width: AppConst.optionMenuSize.width, height: AppConst.optionMenuSize.height), viewModel: viewModel, direction: self!.swipeDirection)
                    self!.optionMenu?.delegate = self
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        guard let `self` = self else { return }
                        self.addSubview(self.optionMenu!)
                    }
                }),
                CircleMenuItem(image: R.image.circlemenu_historyback(), tapAction: { _ in
                    log.warning("ヒストリーバック")
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryBackWebView, object: nil)
                }),
                CircleMenuItem(image: R.image.circlemenu_historyforward(), tapAction: { _ in
                    log.warning("ヒストリーフォワード")
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryForwardWebView, object: nil)
                }),
                CircleMenuItem(image: R.image.circlemenu_search(), tapAction: { _ in
                    log.warning("検索")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] _ in
                        guard let `self` = self else { return }
                        NotificationCenter.default.post(name: .headerViewModelWillBeginEditing, object: true)
                    }
                }),
                CircleMenuItem(image: R.image.circlemenu_close(), tapAction: { _ in
                    log.warning("デリート")
                    NotificationCenter.default.post(name: .baseViewModelWillRemoveWebView, object: nil)
                }),
                CircleMenuItem(image: R.image.circlemenu_add(), tapAction: { _ in
                    log.warning("アッド")
                    NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
                })
            ],
            [
                CircleMenuItem(image: R.image.circlemenu_url(), tapAction: { _ in
                    log.warning("URLコピー")
                    NotificationCenter.default.post(name: .baseViewModelWillCopyUrl, object: nil)
                }),
                CircleMenuItem(image: R.image.circlemenu_autoscroll(), tapAction: { _ in
                    log.warning("自動スクロール")
                    NotificationCenter.default.post(name: .baseViewModelWillAutoScroll, object: nil)
                }),
                CircleMenuItem(image: R.image.circlemenu_copy(), tapAction: { _ in
                    log.warning("コピー")
                    NotificationCenter.default.post(name: .baseViewModelWillCopyWebView, object: nil)
                }),
                CircleMenuItem(image: R.image.circlemenu_form(), tapAction: { _ in
                    log.warning("フォーム")
                    NotificationCenter.default.post(name: .baseViewModelWillRegisterAsForm, object: nil)
                }),
                CircleMenuItem(image: R.image.header_favorite(), tapAction: { _ in
                    log.warning("お気に入り")
                    NotificationCenter.default.post(name: .baseViewModelWillRegisterAsFavorite, object: nil)
                }),
                CircleMenuItem(image: R.image.circlemenu_add_private(), tapAction: { _ in
                    log.warning("プライベート")
                    NotificationCenter.default.post(name: .baseViewModelWillAddPrivateWebView, object: nil)
                })
            ]
        ]
        circleMenu = CircleMenu(frame: CGRect(origin: CGPoint(x: -100, y: -100), size: CGSize(width: kCircleButtonRadius, height: kCircleButtonRadius)) ,menuItems: menuItems)
        circleMenu.swipeDirection = swipeDirection
        circleMenu.delegate = self
        addSubview(circleMenu)
    }
    
// MARK: Private Method
    /// 閲覧履歴、お気に入り、フォームデータを削除する
    func deleteStoreData() {
        // 履歴
        CommonDao.s.deleteCommonHistory(deleteHistoryIds: deleteHistoryIds)
        // お気に入り
        let deleteFavorites = deleteFavoriteIds.map { (id) -> Favorite in
            return FavoriteDataModel.select(id: id).first!
        }
        if deleteFavorites.count > 0 {
            CommonDao.s.delete(data: deleteFavorites)
            NotificationCenter.default.post(name: .baseViewModelWillChangeFavorite, object: nil)
        }
        // フォーム
        let deleteForms = deleteFormIds.map { (id) -> Form in
            return FormDataModel.select(id: id).first!
        }
        if deleteForms.count > 0 {
            FormDataModel.delete(forms: deleteForms)
        }
        deleteHistoryIds = [:]
        deleteFavoriteIds = []
        deleteFormIds = []
    }

// MARK: CircleMenuDelegate
    func circleMenuDidClose() {
        if self.optionMenu == nil {
            UIView.animate(withDuration: 0.15, animations: {
                // ここでおちる
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
        circleMenu.invalidate()
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
    
// MARK: Button Event
    func onTappedOverlay(_ sender: AnyObject) {
        optionMenuDidClose()
    }
}
