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

class SyncViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let gidButton = GIDSignInButton(frame: CGRect.zero)
        view.addSubview(gidButton)
        gidButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        // Do any additional setup after loading the view.
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
