//
//  MenuOrderViewController.swift
//  Qass
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

        initButton.backgroundColor = UIColor.ultraOrange
        closeButton.backgroundColor = UIColor.ultraOrange

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
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.viewModel.initialize()
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: disposeBag)

        // リロード監視
        viewModel.rx_menuOrderViewControllerViewModelDidReload
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_menuOrderViewControllerViewModelDidReload")
                guard let `self` = self else { return }
                self.tableView.reloadData()
                log.eventOut(chain: "rx_menuOrderViewControllerViewModelDidReload")
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - TableViewDataSourceDelegate

extension MenuOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.menuOrderCell.identifier, for: indexPath) as? MenuOrderTableViewCell {
            cell.setRow(row: viewModel.getRow(index: indexPath.row))

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
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
    }
}
