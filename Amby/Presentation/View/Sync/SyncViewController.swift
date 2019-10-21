//
//  SyncViewController.swift
//  Amby
//
//  Created by iori tenma on 2019/06/15.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Firebase
import GoogleSignIn
import SnapKit
import UIKit

class SyncViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var googleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        googleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                GIDSignIn.sharedInstance()?.signIn()
            })
            .disposed(by: rx.disposeBag)

        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
