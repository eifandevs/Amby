//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, BaseLayerDelegate, FrontLayerDelegate, SplashViewControllerDelegate {
    
    private var baseLayer: BaseLayer!
    private var frontLayer: FrontLayer!
    
    private var splash: SplashViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splash = SplashViewController()
        splash?.delegate = self
        splash!.view.frame.size = view.frame.size
        splash!.view.frame.origin = CGPoint.zero
        view.addSubview(splash!.view)
        
        let center = NotificationCenter.default
        // ヘルプ画面の表示通知
        center.addObserver(forName: .baseViewControllerWillPresentHelp, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseViewController Event]: baseViewControllerWillPresentHelp")
            // ヘルプ画面を表示する
            let subtitle = (notification.object as! [String: String])["subtitle"]!
            let message = (notification.object as! [String: String])["message"]!
            let vc = HelpViewController(subtitle: subtitle, message: message)
            self.present(vc, animated: true)
        }
        // レイヤー構造にしたいので、self.viewに対してaddSubViewする(self.view = baseLayerとしない)
        baseLayer = BaseLayer(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size))
        baseLayer.delegate = self
        view.addSubview(baseLayer)

        view.bringSubview(toFront: splash!.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: SplashViewController Delegate
    func splashViewControllerDidEndDrawing() {
        if let splash = splash {
            UIView.animate(withDuration: 0.3, animations: {
                splash.view.alpha = 0
            }, completion: { (finished) in
                if finished {
                    splash.view.removeFromSuperview()
                    splash.removeFromParentViewController()
                    self.splash = nil
                }
            })
        }
    }

// MARK: BaseLayer Delegate
    func baseLayerDidInvalidate(direction: EdgeSwipeDirection) {
        frontLayer = FrontLayer(frame: baseLayer.frame)
        frontLayer.swipeDirection = direction
        frontLayer.delegate = self
        view.addSubview(frontLayer)
    }
    
// MARK: FrontLayer Delegate
    func frontLayerDidInvalidate() {
        self.frontLayer.removeFromSuperview()
        self.frontLayer = nil
        self.baseLayer.validateUserInteraction()
    }

// MARK: WebView Touch
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if Bundle(for: type(of: viewControllerToPresent)).bundleIdentifier == "com.apple.WebKit" {
            if let orgActionSheet = viewControllerToPresent as? UIAlertController, let url = orgActionSheet.title {
                if ((orgActionSheet.preferredStyle == .actionSheet) && (orgActionSheet.title != nil)) {
                    // webviewを長押しされたら、そのURLで新しいタブを作成する
                    if url.hasValidUrl {
                        NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: ["url": url])
                        return
                    }
                }
            }
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
// MARK: Button Event
    func closeHelpViewController() {
        log.debug("閉じる")
    }
}