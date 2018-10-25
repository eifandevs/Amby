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

    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordContainerView = PasswordContainerView.create(in: passcodeStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self

        passwordContainerView.tintColor = UIColor.darkGray
        passwordContainerView.highlightedColor = UIColor.ultraViolet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PasscodeViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_: PasswordContainerView, input: String) {
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }

    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error _: Error?) {
        if success {
            validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasscodeViewController {
    func validation(_ input: String) -> Bool {
        return input == "123456"
    }

    func validationSuccess() {
        print("*️⃣ success!")
        dismiss(animated: true, completion: nil)
    }

    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}
