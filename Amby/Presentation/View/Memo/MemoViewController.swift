//
//  MemoViewController.swift
//  Amby
//
//  Created by tenma on 2018/10/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import RxCocoa
import RxSwift
import UIKit

class MemoViewController: UIViewController {
    @IBOutlet var cancelButton: CornerRadiusButton!
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var stackViewBottomConstraint: NSLayoutConstraint!
    private var initialStackViewBottomConstraint: CGFloat = 0
    private var viewModel: MemoViewControllerViewModel!

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

    convenience init(memo: Memo) {
        self.init(nibName: R.nib.memoViewController.name, bundle: nil)
        viewModel = MemoViewControllerViewModel(memo: memo)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialStackViewBottomConstraint = stackViewBottomConstraint.constant

        textView.delegate = self
        textView.text = viewModel.getMemoText()
        setupRx()
    }

    private func setupRx() {
        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.update(text: self.textView.text)
                self.textView.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
                self.viewModel.close()
            })
            .disposed(by: rx.disposeBag)

        // ボタンタップ
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                // キャンセル
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
                    } else {
                        let margin = 13.f
                        self.stackViewBottomConstraint.constant = keyboardHeight + margin
                    }
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension MemoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_: UITextView) {
        cancelButton.isHidden = false
    }

    func textViewDidEndEditing(_: UITextView) {
        cancelButton.isHidden = true
    }
}
