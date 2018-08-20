//
//  OptionMenuTableView.swift
//  Qas
//
//  Created by User on 2017/06/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class OptionMenuTableView: UIView, ShadowView, OptionMenuView {
    // クローズ通知用RX
    let rx_optionMenuTableViewDidClose = PublishSubject<()>()

    @IBOutlet var tableView: UITableView!
    let viewModel = OptionMenuTableViewModel()
    var detailView: UIView?
    private var selectedIndexPath: IndexPath?
    private var overlay: UIButton?

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

    deinit {
        log.debug("deinit called.")
    }

    func loadNib() {
        let view = Bundle.main.loadNibNamed(R.nib.optionMenuTableView.name, owner: self, options: nil)?.first as! UIView
        view.frame = bounds

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

        addSubview(view)
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
            cell.setViewModelData(row: viewModel.getRow(indexPath: indexPath))
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let overViewMargin = viewModel.getOverViewMargin()

        let marginY = frame.origin.y + frame.size.height + overViewMargin.y > DeviceConst.DEVICE.DISPLAY_SIZE.height ?
            overViewMargin.y - (frame.origin.y + frame.size.height + overViewMargin.y - DeviceConst.DEVICE.DISPLAY_SIZE.height) :
            overViewMargin.y

        // スーパービューに追加するので、自身の座標をたす
        let frameX = frame.origin.x + overViewMargin.x
        let frameY = frame.origin.y + marginY
        let width = AppConst.FRONT_LAYER.OPTION_MENU_SIZE.width
        let height = AppConst.FRONT_LAYER.OPTION_MENU_SIZE.height
        let detailViewFrame = CGRect(x: frameX, y: frameY, width: width, height: height)
        // 詳細ビュー作成
        switch viewModel.getRow(indexPath: indexPath).cellType {
        case .trend:
            self.viewModel.executeOperationDataModel(operation: .trend)
            self.rx_optionMenuTableViewDidClose.onNext(())
            return
        case .report:
            self.viewModel.executeOperationDataModel(operation: .report)
            self.rx_optionMenuTableViewDidClose.onNext(())
            return
        case .contact:
            self.viewModel.executeOperationDataModel(operation: .contact)
            self.rx_optionMenuTableViewDidClose.onNext(())
            return
        case .history:
            let historyTableView = OptionMenuHistoryTableView(frame: detailViewFrame)
            historyTableView.rx_optionMenuHistoryDidClose
                .subscribe({ [weak self] _ in
                    log.eventIn(chain: "rx_optionMenuHistoryDidClose")
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                    log.eventOut(chain: "rx_optionMenuHistoryDidClose")
                })
                .disposed(by: rx.disposeBag)
            // 詳細ビューは保持しておく
            detailView = historyTableView
        case .favorite:
            let favoriteTableView = OptionMenuFavoriteTableView(frame: detailViewFrame)
            favoriteTableView.rx_optionMenuFavoriteDidClose
                .subscribe({ [weak self] _ in
                    log.eventIn(chain: "rx_optionMenuFavoriteDidClose")
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                    log.eventOut(chain: "rx_optionMenuFavoriteDidClose")
                })
                .disposed(by: rx.disposeBag)
            detailView = favoriteTableView
        case .form:
            let formTableView = OptionMenuFormTableView(frame: detailViewFrame)
            formTableView.rx_optionMenuFormDidClose
                .subscribe({ [weak self] _ in
                    log.eventIn(chain: "rx_optionMenuFormDidClose")
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                    log.eventOut(chain: "rx_optionMenuFormDidClose")
                })
                .disposed(by: rx.disposeBag)
            detailView = formTableView
        case .setting:
            let settingTableView = OptionMenuSettingTableView(frame: detailViewFrame)
            settingTableView.rx_optionMenuSettingDidClose
                .subscribe({ [weak self] _ in
                    log.eventIn(chain: "rx_optionMenuSettingDidClose")
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                    log.eventOut(chain: "rx_optionMenuSettingDidClose")
                })
                .disposed(by: rx.disposeBag)
            detailView = settingTableView
        case .help:
            let helpTableView = OptionMenuHelpTableView(frame: detailViewFrame)
            helpTableView.rx_optionMenuHelpDidClose
                .subscribe({ [weak self] _ in
                    log.eventIn(chain: "rx_optionMenuHelpDidClose")
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                    log.eventOut(chain: "rx_optionMenuHelpDidClose")
                })
                .disposed(by: rx.disposeBag)
            detailView = helpTableView
        case .app:
            let appTableView = OptionMenuAppTableView(frame: detailViewFrame)
            appTableView.rx_optionMenuAppDidClose
                .subscribe({ [weak self] _ in
                    log.eventIn(chain: "rx_optionMenuAppDidClose")
                    guard let `self` = self else { return }
                    self.rx_optionMenuTableViewDidClose.onNext(())
                    log.eventOut(chain: "rx_optionMenuAppDidClose")
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
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.back()
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: rx.disposeBag)

        addSubview(overlay!)
    }
}
