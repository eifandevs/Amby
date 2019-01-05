//
//  PasscodeViewController.swift
//  Qass
//
//  Created by tenma on 2018/10/21.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import SmileLock
import UIKit

class PasscodeViewController: UIViewController {
    @IBOutlet var passcodeStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!

    private let viewModel = PasscodeViewControllerViewModel()

    @IBOutlet var closeButton: CornerRadiusButton!
    private var passcodeContainerView: PasswordContainerView!
    private let kPasswordDigit = 6
    /// Observable自動解放
    private let disposeBag = DisposeBag()

    convenience init(isConfirm: Bool) {
        self.init(nibName: R.nib.passcodeViewController.name, bundle: nil)
        viewModel.isConfirm = isConfirm
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRx()

        if viewModel.isConfirm {
            setup()
        } else {
            // パスコード表示済みであればアラート表示
            if viewModel.isRegisterdPasscode {
                passcodeStackView.isHidden = true
            } else {
                setup()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if passcodeContainerView == nil {
            let initializeAction: UIAlertAction = UIAlertAction(title: MessageConst.ALERT.PASSCODE_INITIALIZE, style: .default, handler: { (_: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
                self.viewModel.initializeApp()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: MessageConst.COMMON.CANCEL, style: .cancel, handler: { (_: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            NotificationService.presentAlert(title: MessageConst.COMMON.ERROR, message: MessageConst.ALERT.PASSCODE_ALREADY_REGISTERED, actions: [initializeAction, cancelAction])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setup() {
        passcodeStackView.isHidden = false
        passcodeContainerView = PasswordContainerView.create(in: passcodeStackView, digit: kPasswordDigit)
        passcodeContainerView.delegate = self

        passcodeContainerView.tintColor = UIColor.darkGray
        passcodeContainerView.highlightedColor = UIColor.ultraViolet
    }

    private func setupRx() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.title
            .asObservable()
            .map { $0 }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        // アクション監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                log.eventIn("PasscodeViewControllerViewModel.rx_action")
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .confirm:
                    self.passcodeContainerView.clearInput()
                case .confirmSuccess:
                    self.dismiss(animated: true, completion: nil)
                case .register:
                    self.dismiss(animated: true, completion: nil)
                }
                log.eventOut("PasscodeViewControllerViewModel.rx_action")
            }
            .disposed(by: rx.disposeBag)
        
        // エラー監視
        viewModel.rx_error
            .subscribe { [weak self] error in
                log.eventIn("PasscodeViewControllerViewModel.rx_error")
                guard let `self` = self, let error = error.element, case .confirm = error else { return }
                self.passcodeContainerView.wrongPassword()
                self.passcodeContainerView.clearInput()
                log.eventOut("PasscodeViewControllerViewModel.rx_error")
            }
            .disposed(by: rx.disposeBag)
    }
}

extension PasscodeViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_: PasswordContainerView, input: String) {
        viewModel.input(passcode: input)
    }

    func touchAuthenticationComplete(_ passcodeContainerView: PasswordContainerView, success: Bool, error _: Error?) {}
}
