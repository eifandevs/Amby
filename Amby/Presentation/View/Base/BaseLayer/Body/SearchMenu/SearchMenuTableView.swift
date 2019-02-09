//
//  SearchMenuTableView.swift
//  Qas
//
//  Created by temma on 2017/07/18.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

enum SearchMenuTableViewAction {
    case endEditing
    case close
}

class SearchMenuTableView: UIView {
    /// アクション通知用RX
    let rx_action = PublishSubject<SearchMenuTableViewAction>()

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
        tableView.register(R.nib.searchMenuSuggestTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.searchMenuSuggestCell.identifier)
        tableView.register(R.nib.searchMenuNewsTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.searchMenuNewsCell.identifier)

        // ジェスチャーを登録する
        // ジェスチャーの付け替えをするのでRX化しない
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)

        // キーボード表示の処理
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardDidShow, object: nil)
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                // ジェスチャーを登録する
                self.addGestureRecognizer(self.tapRecognizer)
            }
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide, object: nil)
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                // ジェスチャーを解除する
                self.removeGestureRecognizer(self.tapRecognizer)
            }
            .disposed(by: rx.disposeBag)

        addSubview(tableView)

        // 画面更新通知監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                log.eventIn(chain: "SearchMenuTableViewModel.rx_action. action: \(action)")

                switch action {
                case .update:
                    self.tableView.reloadData()
                    self.alpha = 1
                    if let overlay = self.overlay {
                        overlay.removeFromSuperview()
                        self.overlay = nil
                    }
                case .hide:
                    if self.overlay == nil {
                        self.alpha = 0
                        let button = UIButton(frame: frame)
                        button.backgroundColor = UIColor.clear

                        // ボタンタップ
                        button.rx.tap
                            .subscribe(onNext: { [weak self] in
                                guard let `self` = self else { return }
                                // サーチメニューが透明になっている時にタップ
                                self.rx_action.onNext(.close)
                                button.removeFromSuperview()
                            })
                            .disposed(by: self.rx.disposeBag)

                        self.overlay = button
                        self.superview?.addSubview(button)
                    }
                }
                log.eventOut(chain: "SearchMenuTableViewModel.rx_action. action: \(action)")
            }
            .disposed(by: rx.disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        if let overlay = overlay {
            overlay.removeFromSuperview()
            self.overlay = nil
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// モデルデータ取得
    func getModelData() {
        viewModel.getArticle()
    }

    // MARK: Touch Event

    @objc func tapped(sender _: UITapGestureRecognizer) {
        rx_action.onNext(.endEditing)
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

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            // 記事セル
            return viewModel.newsCellHeight
        }

        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // オートコンプリート表示
            let identifier = R.reuseIdentifier.searchMenuSuggestCell.identifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SearchMenuSuggestTableViewCell {
                cell.setSuggest(suggest: viewModel.suggestCellItem[safe: indexPath.row])
                return cell
            }
        } else if indexPath.section == 1 {
            // 検索履歴表示
            let identifier = R.reuseIdentifier.searchMenuSearchHistoryCell.identifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SearchMenuSearchHistoryTableViewCell {
                cell.setHistory(history: viewModel.searchHistoryCellItem[safe: indexPath.row])
                return cell
            }
        } else if indexPath.section == 2 {
            // 閲覧履歴表示
            let identifier = R.reuseIdentifier.searchMenuCommonHistoryCell.identifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SearchMenuCommonHistoryTableViewCell {
                cell.setHistory(history: viewModel.commonHistoryCellItem[safe: indexPath.row])
                return cell
            }
        } else {
            // 記事表示
            let identifier = R.reuseIdentifier.searchMenuNewsCell.identifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SearchMenuNewsTableViewCell {
                cell.setArticle(article: viewModel.newsItem[safe: indexPath.row])
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionItem[section]
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return viewModel.sectionHeight
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: 11)))
        label.backgroundColor = UIColor.darkGray
        label.text = "   \(viewModel.sectionItem[section])"
        label.textColor = UIColor.white
        label.font = UIFont(name: AppConst.APP.FONT, size: 12)
        return label
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // とりあえずメニューを閉じる
        rx_action.onNext(.close)

        let cell = tableView.cellForRow(at: indexPath)!
        if cell.className == SearchMenuCommonHistoryTableViewCell.className {
            // 閲覧履歴セルタップ
            if let cell = (cell as? SearchMenuCommonHistoryTableViewCell), let history = cell.history {
                viewModel.loadRequest(url: history.url)
            }
        } else if cell.className == SearchMenuSearchHistoryTableViewCell.className {
            // 検索履歴セルタップ
            if let cell = (cell as? SearchMenuSearchHistoryTableViewCell), let history = cell.history {
                viewModel.loadRequest(url: history.title)
            }
        } else if cell.className == SearchMenuSuggestTableViewCell.className {
            // サジェストセルタップ
            if let cell = (cell as? SearchMenuSuggestTableViewCell), let suggest = cell.suggest {
                viewModel.loadRequest(url: suggest)
            }
        } else {
            // ニュースセルタップ
            if let cell = (cell as? SearchMenuNewsTableViewCell), let url = cell.article?.url {
                viewModel.loadRequest(url: url)
            }
        }
    }
}
