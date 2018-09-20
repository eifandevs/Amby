//
//  OpenSourceViewController.swift
//  Qass
//
//  Created by tenma on 2018/09/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OpenSourceViewController: UIViewController {
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var tableView: UITableView!

    let viewModel = OpenSourceViewControllerViewModel()

    convenience init() {
        self.init(nibName: R.nib.openSourceViewController.name, bundle: nil)
    }

    deinit {
        log.debug("deinit called.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // テーブルビュー監視
        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedRowHeight = viewModel.cellHeight

        // カスタムビュー登録
        tableView.register(R.nib.openSourceTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.openSourceCell.identifier)

        closeButton.backgroundColor = UIColor.ultraOrange
        // Do any additional setup after loading the view.
        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TableViewDataSourceDelegate

extension OpenSourceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.openSourceCell.identifier, for: indexPath) as? OpenSourceTableViewCell {
            cell.setRow(row: viewModel.getRow(index: indexPath.row))

            return cell
        }
        return UITableViewCell()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - TableViewDelegate

extension OpenSourceViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.invert(index: indexPath.row)
        log.debug("tapeed!!!!!!!!!!!!!1")
    }
}
