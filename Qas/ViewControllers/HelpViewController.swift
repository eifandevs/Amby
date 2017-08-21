//
//  HelpViewController.swift
//  Qas
//
//  Created by temma on 2017/08/20.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var gifImageView: UIImageView!
    
    private var subtitle: String = ""
    private var message: String = ""
    
    convenience init(subtitle: String, message: String) {
        self.init(nibName: R.nib.helpViewController.name, bundle: nil)
        self.subtitle = subtitle
        self.message = message
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        subtitleLabel.text = subtitle
        messageLabel.text = message
        contentView.backgroundColor = UIColor.white
        closeButton.addTarget(self, action: #selector(self.onTappedCloseButton(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onTappedCloseButton(_ sender: AnyObject) {
        log.debug("閉じる")
    }

}
