//
//  OpenSourceViewController.swift
//  Qass
//
//  Created by tenma on 2018/09/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class OpenSourceViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var closeButton: CornerRadiusButton!

    convenience init() {
        self.init(nibName: R.nib.openSourceViewController.name, bundle: nil)
    }

    deinit {
        log.debug("deinit called.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
