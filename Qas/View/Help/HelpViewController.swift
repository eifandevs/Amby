//
//  HelpViewController.swift
//  Qas
//
//  Created by temma on 2017/08/20.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import VerticalAlignmentLabel

class HelpViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var closeButton: CornerRadiusButton!
    @IBOutlet weak var messageLabel: VerticalAlignmentLabel!
    @IBOutlet weak var subtitleLabel: VerticalAlignmentLabel!
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
        closeButton.backgroundColor = UIColor.brilliantBlue
        closeButton.addTarget(self, action: #selector(self.onTappedCloseButton(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onTappedCloseButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
