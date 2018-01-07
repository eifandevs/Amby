//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var baseLayer: BaseLayer!
    private var frontLayer: FrontLayer!
    private let viewModel = BaseViewControllerViewModel()
    
    private var splash: SplashViewController?
    var isActive = true
    private var onceExec = OnceExec()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isActive = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewModel.delegate = self
        
        onceExec.call {
            // iPhoneX対応
            if #available(iOS 11.0, *) {
                let insets = self.view.safeAreaInsets
                if Util.isiPhoneX() {
                    AppConst.BASE_LAYER_HEADER_HEIGHT = AppConst.BASE_LAYER_THUMBNAIL_SIZE.height * 1.3 + insets.top
                    AppConst.BASE_LAYER_HEADER_PROGRESS_MARGIN = AppConst.BASE_LAYER_HEADER_PROGRESS_BAR_HEIGHT * 2.2
                    AppConst.BASE_LAYER_FOOTER_HEIGHT = AppConst.BASE_LAYER_THUMBNAIL_SIZE.height + insets.bottom
                    AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT = AppConst.BASE_LAYER_HEADER_HEIGHT / 2.5
                    AppConst.BASE_LAYER_THUMBNAIL_SIZE = CGSize(width: UIScreen.main.bounds.size.width / 4.3, height: (UIScreen.main.bounds.size.width / 3.4) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)
                } else {
                    AppConst.BASE_LAYER_HEADER_HEIGHT = AppConst.BASE_LAYER_THUMBNAIL_SIZE.height * 1.3
                    AppConst.BASE_LAYER_HEADER_PROGRESS_MARGIN = AppConst.BASE_LAYER_HEADER_PROGRESS_BAR_HEIGHT
                    AppConst.BASE_LAYER_FOOTER_HEIGHT = AppConst.BASE_LAYER_THUMBNAIL_SIZE.height
                    AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT = AppConst.BASE_LAYER_HEADER_HEIGHT / 2
                    AppConst.BASE_LAYER_THUMBNAIL_SIZE = CGSize(width: UIScreen.main.bounds.size.width / 4.3, height: (UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)
                }
            }

            splash = SplashViewController()
            splash?.delegate = self
            splash!.view.frame.size = view.frame.size
            splash!.view.frame.origin = CGPoint.zero
            view.addSubview(splash!.view)

            // ページ情報初期化
            PageHistoryDataModel.s.initialize()
            
            // レイヤー構造にしたいので、self.viewに対してaddSubViewする(self.view = baseLayerとしない)
            baseLayer = BaseLayer(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size))
            baseLayer.delegate = self
            view.addSubview(baseLayer)

            view.bringSubview(toFront: splash!.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: WebView Touch
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if Bundle(for: type(of: viewControllerToPresent)).bundleIdentifier == "com.apple.WebKit" {
            if let orgActionSheet = viewControllerToPresent as? UIAlertController, let url = orgActionSheet.title {
                if ((orgActionSheet.preferredStyle == .actionSheet) && (orgActionSheet.title != nil)) {
                    // webviewを長押しされたら、そのURLで新しいタブを作成する
                    if url.hasValidUrl {
                        viewModel.insertPageHistoryDataModel(url: url)
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

// MARK: BaseLayer Delegate
extension BaseViewController: BaseLayerDelegate {
    func baseLayerDidInvalidate(direction: EdgeSwipeDirection) {
        frontLayer = FrontLayer(frame: baseLayer.frame, swipeDirection: direction)
        frontLayer.delegate = self
        view.addSubview(frontLayer)
    }
}

// MARK: FrontLayer Delegate
extension BaseViewController: FrontLayerDelegate {
    func frontLayerDidInvalidate() {
        self.frontLayer.removeFromSuperview()
        self.frontLayer = nil
        self.baseLayer.validateUserInteraction()
    }
}

// MARK: SplashViewController Delegate
extension BaseViewController: SplashViewControllerDelegate {
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
}

// MARK: BaseViewControllerViewModel Delegate
extension BaseViewController: BaseViewControllerViewModelDelegate {
    func baseViewControllerViewModelDelegateDidPresentHelp(subtitle: String, message: String) {
        let vc = HelpViewController(subtitle: subtitle, message: message)
        self.present(vc, animated: true)
    }
}
