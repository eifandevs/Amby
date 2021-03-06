//
//  MenuOrderViewController.swift
//  Amby
//
//  Created by tenma on 2018/08/20.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class MenuOrderViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var initButton: CornerRadiusButton!
    @IBOutlet var okButton: CornerRadiusButton!

    private let viewModel = MenuOrderViewControllerViewModel()

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        // カスタムビュー登録
        tableView.register(R.nib.menuOrderTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.menuOrderCell.identifier)

        setupRx()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupRx() {
        initButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.initialize()
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        okButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.changeOrder()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        // リロード監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                log.eventIn(chain: "MenuOrderViewControllerViewModel.rx_action")
                guard let `self` = self, let action = action.element, case .reload = action else { return }
                self.tableView.reloadData()
                log.eventOut(chain: "MenuOrderViewControllerViewModel.rx_action")
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - TableViewDataSourceDelegate

extension MenuOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.menuOrderCell.identifier, for: indexPath) as? MenuOrderTableViewCell {
            let row = viewModel.getRow(index: indexPath.row)
            cell.setRow(row: row, order: viewModel.getOrder(operation: row.operation))

            return cell
        }
        return UITableViewCell()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }
}

// MARK: - TableViewDelegate

extension MenuOrderViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.sort(operation: viewModel.getRow(index: indexPath.row).operation)
    }
}
