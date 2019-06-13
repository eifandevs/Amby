//
//  ChatViewController.swift
//  Report
//
//  Created by iori tenma on 2019/05/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import UIKit
import WebKit

public class ChatViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView(frame: CGRect(origin: CGPoint.zero, size: view.bounds.size))
        view.addSubview(webView)
        let path = Bundle.main.privateFrameworksPath! + "/Report.framework/dist/index.html"
        let url = URL(fileURLWithPath: path)
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }

}
