//
//  ReportViewController.swift
//  Amby
//
//  Created by tenma on 2018/08/20.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import VerticalAlignmentLabel

class ReportViewController: UIViewController {
    @IBOutlet var titleLabel: VerticalAlignmentLabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var listButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var stackViewBottomConstraint: NSLayoutConstraint!

    private var initialStackViewBottomConstraint: CGFloat = 0
    private let viewModel = ReportViewControllerViewModel()

    private let rx_keyboardHeight = Observable
        .merge([
            NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
                .map { notification -> CGFloat in
                    (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
            NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
                .map { _ -> CGFloat in
                    0
                }
        ])

    convenience init() {
        self.init(nibName: R.nib.reportViewController.name, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        initialStackViewBottomConstraint = stackViewBottomConstraint.constant

        cancelButton.isHidden = true
        listButton.isHidden = false

        setupRx()

        let osver = Util.getOsInfo()
        let device = Util.getDeviceInfo()
        // メッセージテンプレ入力
        textView.text = "【 端末 】\n  \(device)\n\n【 OS 】\n  \(osver)\n\n【 ご報告内容 】\n  メッセージを入力"
    }

    private func setupRx() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.textView.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)

        listButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.openList()
                self.textView.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)

        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.send(title: MessageConst.REPORT.TITLE, message: self.textView.text)
                self.textView.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)

        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.textView.resignFirstResponder()
            })
            .disposed(by: rx.disposeBag)

        rx_keyboardHeight
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] keyboardHeight in
                guard let `self` = self else { return }

                if let keyboardHeight = keyboardHeight.element {
                    if keyboardHeight == 0 {
                        self.stackViewBottomConstraint.constant = self.initialStackViewBottomConstraint
                        self.titleLabel.isHidden = false
                        self.subTitleLabel.isHidden = false
                    } else {
                        let margin = 13.f
                        self.stackViewBottomConstraint.constant = keyboardHeight + margin
                        self.titleLabel.isHidden = true
                        self.subTitleLabel.isHidden = true
                    }
                }
            }
            .disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ReportViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_: UITextView) {
        cancelButton.isHidden = false
        listButton.isHidden = true
    }

    func textViewDidEndEditing(_: UITextView) {
        cancelButton.isHidden = true
        listButton.isHidden = false
    }
}
