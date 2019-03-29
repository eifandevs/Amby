//
//  HtmlAnalysisViewController.swift
//  Amby
//
//  Created by tenma on 2019/03/18.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import CommonUtil
import RxCocoa
import RxSwift
import UIKit

class HtmlAnalysisViewController: UIViewController {
    @IBOutlet var htmlTextView: UITextView!
    @IBOutlet var closeButton: CornerRadiusButton!

    private var html: String!

    convenience init(html: String) {
        self.init(nibName: R.nib.htmlAnalysisViewController.name, bundle: nil)
        self.html = html.html2String
    }

    deinit {
        log.debug("deinit called.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // データ投入
        htmlTextView.text = html

        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
