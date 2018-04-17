//
//  SearchMenuTableView.swift
//  Qas
//
//  Created by temma on 2017/07/18.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class SearchMenuTableView: UIView {
    /// 編集終了通知用RX
    let rx_searchMenuDidEndEditing = PublishSubject<()>()
    /// メニュークローズ通知用RX
    let rx_searchMenuDidClose = PublishSubject<()>()

    private let viewModel: SearchMenuTableViewModel = SearchMenuTableViewModel()
    private var tapRecognizer: UITapGestureRecognizer!
    private var overlay: UIButton?

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

        // カスタムビュー登録
        tableView.register(R.nib.searchMenuCommonHistoryTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.searchMenuCommonHistoryCell.identifier)
        tableView.register(R.nib.searchMenuSearchHistoryTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.searchMenuSearchHistoryCell.identifier)
        tableView.register(SearchMenuNewsTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(SearchMenuNewsTableViewCell.self))

        // ジェスチャーを登録する
        // ジェスチャーの付け替えをするのでRX化しない
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)

        // キーボード表示の処理
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardDidShow, object: nil)
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_UIKeyboardDidShow")
                guard let `self` = self else { return }
                // ジェスチャーを登録する
                self.addGestureRecognizer(self.tapRecognizer)
                log.eventOut(chain: "rx_UIKeyboardDidShow")
            }
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide, object: nil)
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_UIKeyboardWillHide")
                guard let `self` = self else { return }
                // ジェスチャーを解除する
                self.removeGestureRecognizer(self.tapRecognizer)
                log.eventIn(chain: "rx_UIKeyboardWillHide")
            }
            .disposed(by: rx.disposeBag)

        addSubview(tableView)

        // 画面更新通知監視
        viewModel.rx_searchMenuViewWillUpdateLayout
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_searchMenuViewWillUpdateLayout")
                guard let `self` = self else { return }
                self.tableView.reloadData()
                self.alpha = 1
                if let overlay = self.overlay {
                    overlay.removeFromSuperview()
                    self.overlay = nil
                }
                log.eventOut(chain: "rx_searchMenuViewWillUpdateLayout")
            }.disposed(by: rx.disposeBag)

        // 画面無効化監視
        viewModel.rx_searchMenuViewWillHide
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_searchMenuViewWillHide")
                guard let `self` = self else { return }
                if self.overlay == nil {
                    self.alpha = 0
                    let button = UIButton(frame: frame)
                    button.backgroundColor = UIColor.clear

                    // ボタンタップ
                    button.rx.tap
                        .subscribe(onNext: { [weak self] in
                            log.eventIn(chain: "rx_tap")
                            guard let `self` = self else { return }
                            // サーチメニューが透明になっている時にタップ
                            self.rx_searchMenuDidClose.onNext(())
                            button.removeFromSuperview()
                            log.eventOut(chain: "rx_tap")
                        })
                        .disposed(by: self.rx.disposeBag)

                    self.overlay = button
                    self.superview?.addSubview(button)
                }
                log.eventOut(chain: "rx_searchMenuViewWillHide")
            }.disposed(by: rx.disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        if let overlay = overlay {
            overlay.removeFromSuperview()
            self.overlay = nil
        }
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getModelData() {
    }

    // MARK: Touch Event

    @objc func tapped(sender _: UITapGestureRecognizer) {
        rx_searchMenuDidEndEditing.onNext(())
    }
}

// MARK: UITableView Delegate

extension SearchMenuTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.suggestCellItem.count
        case 1:
            return viewModel.searchHistoryCellItem.count
        case 2:
            return viewModel.commonHistoryCellItem.count
        case 3:
            return viewModel.newsItem.count
        default:
            return 0
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.sectionItem.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // オートコンプリート表示
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = viewModel.suggestCellItem.count > 0 ? viewModel.suggestCellItem[indexPath.row] : ""
            return cell
        } else if indexPath.section == 1 {
            // 検索履歴表示
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchMenuSearchHistoryCell.identifier, for: indexPath) as! SearchMenuSearchHistoryTableViewCell
            cell.textLabel?.text = viewModel.searchHistoryCellItem.count > 0 ? viewModel.searchHistoryCellItem[indexPath.row].title : ""
            return cell
        } else if indexPath.section == 2 {
            // 閲覧履歴表示
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchMenuCommonHistoryCell.identifier, for: indexPath) as! SearchMenuCommonHistoryTableViewCell
            cell.setHistory(history: viewModel.commonHistoryCellItem[indexPath.row])
            return cell
        } else {
            // 記事表示
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchMenuNewsTableViewCell.self), for: indexPath) as! SearchMenuNewsTableViewCell
            cell.setArticle(article: viewModel.newsItem[indexPath.row])
            return cell
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionItem[section]
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return AppConst.FRONT_LAYER_TABLE_VIEW_SECTION_HEIGHT
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: 11)))
        label.backgroundColor = UIColor.black
        label.text = "   \(viewModel.sectionItem[section])"
        label.textColor = UIColor.white
        label.font = UIFont(name: AppConst.APP_FONT, size: 12)
        return label
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // とりあえずメニューを閉じる
        rx_searchMenuDidClose.onNext(())

        let cell = tableView.cellForRow(at: indexPath)!
        if cell.className == SearchMenuCommonHistoryTableViewCell.className {
            let text = (cell as! SearchMenuCommonHistoryTableViewCell).urlLabel.text!
            viewModel.executeOperationDataModel(operation: .search, url: text)
        } else {
            let text = cell.textLabel!.text!
            viewModel.executeOperationDataModel(operation: .search, url: text)
        }
    }
}
