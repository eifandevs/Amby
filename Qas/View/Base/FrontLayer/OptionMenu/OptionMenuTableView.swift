//
//  OptionMenuTableView.swift
//  Qas
//
//  Created by User on 2017/06/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class OptionMenuTableView: UIView, ShadowView, OptionMenuView {
    // クローズ通知用RX
    let rx_optionMenuTableViewDidClose = PublishSubject<()>()
    
    @IBOutlet weak var tableView: UITableView!
    let viewModel = OptionMenuTableViewModel()
    var detailView: UIView?
    private var selectedIndexPath: IndexPath?
    
    convenience init(frame: CGRect, swipeDirection: EdgeSwipeDirection) {
        self.init(frame: frame)
        viewModel.swipeDirection = swipeDirection
        loadNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        
        // 影
        addMenuShadow()
        
        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self
        
        // OptionMenuProtocol
        _ = setup(tableView: tableView)

        // カスタムビュー登録
        tableView.register(R.nib.optionMenuTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuCell.identifier)

        // 履歴情報を永続化しておく
        viewModel.storeHistory()

        self.addSubview(view)
    }
}

// MARK: - TableViewDataSourceDelegate
extension OptionMenuTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuCell.identifier, for: indexPath) as! OptionMenuTableViewCell
        cell.setViewModelData(row: viewModel.getRow(indexPath: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
}

// MARK: - TableViewDelegate
extension OptionMenuTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let overViewMargin = viewModel.getOverViewMargin()

        let marginY = frame.origin.y + frame.size.height + overViewMargin.y > DeviceConst.DISPLAY_SIZE.height ?
                      overViewMargin.y - (frame.origin.y + frame.size.height + overViewMargin.y - DeviceConst.DISPLAY_SIZE.height) :
                      overViewMargin.y

        // スーパービューに追加するので、自身の座標をたす
        let detailViewFrame = CGRect(x: frame.origin.x + overViewMargin.x, y: frame.origin.y + marginY, width: AppConst.FRONT_LAYER_OPTION_MENU_SIZE.width, height: AppConst.FRONT_LAYER_OPTION_MENU_SIZE.height)
        // 詳細ビュー作成
        switch viewModel.getRow(indexPath: indexPath).cellType {
        case .history:
            let historyTableView = OptionMenuHistoryTableView(frame: detailViewFrame)
            historyTableView.rx_optionMenuHistoryDidClose
                .subscribe({ [weak self] _ in
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                })
                .disposed(by: rx.disposeBag)
            // 詳細ビューは保持しておく
            detailView = historyTableView
            superview!.addSubview(historyTableView)
        case .favorite:
            let favoriteTableView = OptionMenuFavoriteTableView(frame: detailViewFrame)
            favoriteTableView.rx_optionMenuFavoriteDidClose
                .subscribe({ [weak self] _ in
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                })
                .disposed(by: rx.disposeBag)
            detailView = favoriteTableView
            superview!.addSubview(favoriteTableView)
        case .form:
            let formTableView = OptionMenuFormTableView(frame: detailViewFrame)
            formTableView.rx_optionMenuFormDidClose
                .subscribe({ [weak self] _ in
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                })
                .disposed(by: rx.disposeBag)
            detailView = formTableView
            superview!.addSubview(formTableView)
        case .setting:
            let settingTableView = OptionMenuSettingTableView(frame: detailViewFrame)
            settingTableView.rx_optionMenuSettingDidClose
                .subscribe({ [weak self] _ in
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                })
                .disposed(by: rx.disposeBag)
            detailView = settingTableView
            superview!.addSubview(settingTableView)
        case .help:
            let helpTableView = OptionMenuHelpTableView(frame: detailViewFrame)
            helpTableView.rx_optionMenuHelpDidClose
                .subscribe({ [weak self] _ in
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                })
                .disposed(by: rx.disposeBag)
            detailView = helpTableView
            superview!.addSubview(helpTableView)
        case .app:
            let appTableView = OptionMenuAppTableView(frame: detailViewFrame)
            appTableView.rx_optionMenuAppDidClose
                .subscribe({ [weak self] _ in
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                })
                .disposed(by: rx.disposeBag)
            detailView = appTableView
            superview!.addSubview(appTableView)
        }
        
        // オーバーレイ表示
        let overlay = UIButton(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        overlay.backgroundColor = UIColor.clear

        // ボタンタップ
        overlay.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                // overlay削除
                overlay.removeFromSuperview()

                // 選択状態解除
                if let selectedIndexPath = self.selectedIndexPath {
                    tableView.deselectRow(at: selectedIndexPath, animated: false)
                    self.selectedIndexPath = nil
                }

                if let detailView = self.detailView {
                    // 詳細ビューを表示していれば、削除する
                    UIView.animate(withDuration: 0.15, animations: {
                        detailView.alpha = 0
                    }, completion: { (finished) in
                        if finished {
                            detailView.removeFromSuperview()
                            self.detailView = nil
                        }
                    })
                }
            })
            .disposed(by: rx.disposeBag)

        addSubview(overlay)
    }
}
