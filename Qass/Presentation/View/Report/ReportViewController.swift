//
//  ReportViewController.swift
//  Qass
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

    public let rx_keyboardHeight = Observable
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

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    convenience init() {
        self.init(nibName: R.nib.reportViewController.name, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialStackViewBottomConstraint = stackViewBottomConstraint.constant

        cancelButton.isHidden = true
        listButton.isHidden = false

        setupRx()
    }

    private func setupRx() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.textView.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: disposeBag)

        listButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.viewModel.openList()
                self.textView.resignFirstResponder()
                self.dismiss(animated: true, completion: nil)
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.textView.resignFirstResponder()
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: disposeBag)

        rx_keyboardHeight
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] keyboardHeight in
                log.eventIn(chain: "rx_keyboardHeight")
                guard let `self` = self else { return }

                if let keyboardHeight = keyboardHeight.element {
                    if keyboardHeight == 0 {
                        self.stackViewBottomConstraint.constant = self.initialStackViewBottomConstraint
                        self.cancelButton.isHidden = true
                        self.listButton.isHidden = false
                        self.titleLabel.isHidden = false
                        self.subTitleLabel.isHidden = false
                    } else {
                        let margin = 13.f
                        self.stackViewBottomConstraint.constant = keyboardHeight + margin
                        self.cancelButton.isHidden = false
                        self.listButton.isHidden = true
                        self.titleLabel.isHidden = true
                        self.subTitleLabel.isHidden = true
                    }
                }
                log.eventOut(chain: "rx_keyboardHeight")
            }
            .disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
