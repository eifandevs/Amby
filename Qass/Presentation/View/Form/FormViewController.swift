//
//  FormViewController.swift
//  Qass
//
//  Created by tenma on 2018/10/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Model
import RxCocoa
import RxSwift
import UIKit

class FormViewController: UIViewController {
    private let viewModel = FormViewControllerViewModel()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: CornerRadiusButton!

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    convenience init(form: Form) {
        self.init(nibName: R.nib.formViewController.name, bundle: nil)
        viewModel.form = form
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // テーブルビュー監視
        tableView.dataSource = self

        tableView.estimatedRowHeight = viewModel.cellHeight

        // カスタムビュー登録
        tableView.register(R.nib.formTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.formCell.identifier)

        setupRx()
    }

    private func setupRx() {
        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - TableViewDataSourceDelegate

extension FormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.formCell.identifier, for: indexPath) as? FormTableViewCell {
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
