//
//  OptionMenuTableView.swift
//  Amby
//
//  Created by User on 2017/06/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

enum OptionMenuTableViewAction {
    case close
}

class OptionMenuTableView: UIView, ShadowView, OptionMenuView {
    // アクション通知用RX
    let rx_action = PublishSubject<OptionMenuTableViewAction>()

    private let tableView = UITableView()
    private let viewModel = OptionMenuTableViewModel()
    private var detailView: UIView?
    private var selectedIndexPath: IndexPath?
    private var overlay: UIButton?

    convenience init(frame: CGRect, swipeDirection: EdgeSwipeDirection) {
        self.init(frame: frame)
        viewModel.swipeDirection = swipeDirection
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    deinit {
        log.debug("deinit called.")
    }

    func setup() {
        // 影
        addMenuShadow()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // OptionMenuProtocol
        _ = setupLayout(tableView: tableView)

        // カスタムセル登録
        tableView.register(R.nib.optionMenuTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuCell.identifier)

        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(0)
            make.right.equalTo(snp.right).offset(0)
            make.top.equalTo(snp.top).offset(0)
            make.bottom.equalTo(snp.bottom).offset(0)
        }
    }

    private func back() {
        // overlay削除
        if let overlay = overlay {
            overlay.removeFromSuperview()
        }

        // 選択状態解除
        if let selectedIndexPath = self.selectedIndexPath {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
            self.selectedIndexPath = nil
        }

        if let detailView = self.detailView {
            // 詳細ビューを表示していれば、削除する
            UIView.animate(withDuration: 0.15, animations: {
                detailView.alpha = 0
            }, completion: { finished in
                if finished {
                    detailView.removeFromSuperview()
                    self.detailView = nil
                }
            })
        }
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.optionMenuCell.identifier, for: indexPath) as? OptionMenuTableViewCell {
            cell.setRow(row: viewModel.getRow(indexPath: indexPath))
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellCount
    }
}

// MARK: - TableViewDelegate

extension OptionMenuTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let overViewMargin = viewModel.getOverViewMargin()

        let marginY = frame.origin.y + frame.size.height + overViewMargin.y > AppConst.DEVICE.DISPLAY_SIZE.height ?
            overViewMargin.y - (frame.origin.y + frame.size.height + overViewMargin.y - AppConst.DEVICE.DISPLAY_SIZE.height) :
            overViewMargin.y

        // スーパービューに追加するので、自身の座標をたす
        let frameX = frame.origin.x + overViewMargin.x
        let frameY = frame.origin.y + marginY
        let width = AppConst.FRONT_LAYER.OPTION_MENU_SIZE.width
        let height = AppConst.FRONT_LAYER.OPTION_MENU_SIZE.height
        let detailViewFrame = CGRect(x: frameX, y: frameY, width: width, height: height)
        // 詳細ビュー作成
        switch viewModel.getRow(indexPath: indexPath).cellType {
        case .tabGroup:
            let historyTableView = OptionMenuTabGroupTableView(frame: detailViewFrame)
            historyTableView.rx_action
                .subscribe({ [weak self] action in
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.rx_action.onNext(.close)
                })
                .disposed(by: rx.disposeBag)
            // 詳細ビューは保持しておく
            detailView = historyTableView
        case .trend:
            viewModel.loadTrend()
            rx_action.onNext(.close)
            return
        case .history:
            let historyTableView = OptionMenuHistoryTableView(frame: detailViewFrame)
            historyTableView.rx_action
                .subscribe({ [weak self] action in
                    log.eventIn(chain: "OptionMenuHistoryTableView.rx_action")
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.rx_action.onNext(.close)
                    log.eventOut(chain: "OptionMenuHistoryTableView.rx_action")
                })
                .disposed(by: rx.disposeBag)
            // 詳細ビューは保持しておく
            detailView = historyTableView
        case .favorite:
            let favoriteTableView = OptionMenuFavoriteTableView(frame: detailViewFrame)
            favoriteTableView.rx_action
                .subscribe({ [weak self] action in
                    log.eventIn(chain: "OptionMenuFavoriteTableView.rx_action")
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.rx_action.onNext(.close)
                    log.eventOut(chain: "OptionMenuFavoriteTableView.rx_action")
                })
                .disposed(by: rx.disposeBag)
            detailView = favoriteTableView
        case .form:
            let formTableView = OptionMenuFormTableView(frame: detailViewFrame)
            formTableView.rx_action
                .subscribe({ [weak self] action in
                    log.eventIn(chain: "OptionMenuFormTableView.rx_action")
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.rx_action.onNext(.close)
                    log.eventOut(chain: "OptionMenuFormTableView.rx_action")
                })
                .disposed(by: rx.disposeBag)
            detailView = formTableView
        case .memo:
            let memoTableView = OptionMenuMemoTableView(frame: detailViewFrame)
            detailView = memoTableView
        case .setting:
            let settingTableView = OptionMenuSettingTableView(frame: detailViewFrame)
            settingTableView.rx_action
                .subscribe({ [weak self] action in
                    log.eventIn(chain: "OptionMenuSettingTableView.rx_action")
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.rx_action.onNext(.close)
                    log.eventOut(chain: "OptionMenuSettingTableView.rx_action")
                })
                .disposed(by: rx.disposeBag)
            detailView = settingTableView
        case .help:
            let helpTableView = OptionMenuHelpTableView(frame: detailViewFrame)
            detailView = helpTableView
        case .cooperation:
            let cooperationTableView = OptionMenuCooperationTableView(frame: detailViewFrame)
            cooperationTableView.rx_action
                .subscribe({ [weak self] action in
                    log.eventIn(chain: "OptionMenuCooperationTableView.rx_action")
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.rx_action.onNext(.close)
                    log.eventOut(chain: "OptionMenuCooperationTableView.rx_action")
                })
                .disposed(by: rx.disposeBag)
            detailView = cooperationTableView
        case .analysisHtml:
            viewModel.analysisHtml()
            rx_action.onNext(.close)
            return
        case .app:
            let appTableView = OptionMenuAppTableView(frame: detailViewFrame)
            appTableView.rx_action
                .subscribe({ [weak self] action in
                    log.eventIn(chain: "OptionMenuAppTableView.rx_action")
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.rx_action.onNext(.close)
                    log.eventOut(chain: "OptionMenuAppTableView.rx_action")
                })
                .disposed(by: rx.disposeBag)
            detailView = appTableView
        }

        superview!.addSubview(detailView!)

        // オーバーレイ表示
        overlay = UIButton(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        overlay!.backgroundColor = UIColor.clear

        // ボタンタップ
        overlay!.rx.tap
            .observeOn(MainScheduler.asyncInstance) // アニメーションさせるのでメインスレッドで実行
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.back()
            })
            .disposed(by: rx.disposeBag)

        addSubview(overlay!)
    }
}
