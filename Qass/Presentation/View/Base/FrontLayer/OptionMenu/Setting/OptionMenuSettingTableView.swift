//
//  OptionMenuSettingTableView.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class OptionMenuSettingTableView: UIView, ShadowView, OptionMenuView {
    // メニュークローズ通知用RX
    let rx_optionMenuSettingDidClose = PublishSubject<()>()

    let viewModel = OptionMenuSettingTableViewModel()
    @IBOutlet var tableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    deinit {
        log.debug("deinit called.")
    }

    func loadNib() {
        if let view = Bundle.main.loadNibNamed(R.nib.optionMenuSettingTableView.name, owner: self, options: nil)?.first as? UIView {
            view.frame = bounds

            // 影
            addMenuShadow()

            // テーブルビュー監視
            tableView.delegate = self
            tableView.dataSource = self

            // OptionMenuProtocol
            _ = setup(tableView: tableView)

            // カスタムビュー登録
            tableView.register(R.nib.optionMenuSettingSliderTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuSettingSliderCell.identifier)
            tableView.register(R.nib.optionMenuSettingSwitchTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuSettingSwitchCell.identifier)
            tableView.register(R.nib.optionMenuSettingTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.optionMenuSettingCell.identifier)

            addSubview(view)
        }
    }
}

// MARK: - TableViewDataSourceDelegate

extension OptionMenuSettingTableView: UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.getRow(indexPath: indexPath)

        if row.cellType == .autoScroll {
            let identifier = R.reuseIdentifier.optionMenuSettingSliderCell.identifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuSettingSliderTableViewCell {
                cell.selectionStyle = .none
                return cell
            }
        } else if row.cellType == .windowConfirm {
            let identifier = R.reuseIdentifier.optionMenuSettingSwitchCell.identifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuSettingSwitchTableViewCell {
                cell.selectionStyle = .none
                return cell
            }
        } else {
            let identifier = R.reuseIdentifier.optionMenuSettingCell.identifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OptionMenuSettingTableViewCell {
                cell.setRow(row: row)
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: PaddingLabel = PaddingLabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: viewModel.sectionHeight)))
        label.backgroundColor = UIColor.ultraViolet
        label.textAlignment = .left
        label.text = viewModel.getSection(section: section).title
        label.textColor = UIColor.white
        label.font = UIFont(name: AppConst.APP.FONT, size: viewModel.sectionFontSize)
        return label
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return viewModel.sectionHeight
    }

    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount(section: section)
    }
}

// MARK: - TableViewDelegate

extension OptionMenuSettingTableView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.getRow(indexPath: indexPath)
        switch row.cellType {
        case .passcode:
            viewModel.openPasscodeSetting()
        case .menu:
            viewModel.openMenuOrder()
        case .commonHistory:
            viewModel.deleteHistory()
        case .bookMark:
            viewModel.deleteFavorite()
        case .form:
            viewModel.deleteForm()
        case .searchHistory:
            viewModel.deleteSearchHistory()
        case .cookies:
            viewModel.deleteCookies()
        case .siteData:
            viewModel.deleteCaches()
        case .all:
            viewModel.deleteAll()
        default:
            break
        }
        // メニューは閉じない
//        rx_optionMenuSettingDidClose.onNext(())
    }
}
