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
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var webView: HtmlAnalysisWebView!

    private var html: String!

    convenience init(html: String) {
        self.init(nibName: R.nib.htmlAnalysisViewController.name, bundle: nil)
        self.html = html
    }

    deinit {
        log.debug("deinit called.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)

        webView.navigationDelegate = self
        webView.uiDelegate = self

        webView.loadShaperHtml()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: WKNavigationDelegate, UIWebViewDelegate, WKUIDelegate

extension HtmlAnalysisViewController: WKNavigationDelegate, WKUIDelegate {
    /// force touchを無効にする
    func webView(_: WKWebView, shouldPreviewElement _: WKPreviewElementInfo) -> Bool {
        return false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        guard let wv = webView as? HtmlAnalysisWebView else { return }
        log.debug("loading start.")
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        guard let wv = webView as? HtmlAnalysisWebView else { return }
        log.debug("loading finish. html: \(html)")
//        wv.shape(html: html).then { _ in }
        wv.shape(html: html).then { _ in }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        log.error("[error url]\(String(describing: (error as NSError).userInfo["NSErrorFailingURLKey"])). code: \((error as NSError).code)")

        guard let wv = webView as? HtmlAnalysisWebView else { return }
    }
}
