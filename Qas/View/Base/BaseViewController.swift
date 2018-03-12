//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class BaseViewController: UIViewController {
    
    private var baseLayer: BaseLayer!
    private var frontLayer: FrontLayer!
    private let viewModel = BaseViewControllerViewModel()
    
    private var splash: SplashViewController?
    var isActive = true
    
    /// 初回実行用
    private var onceExec = OnceExec()
    
    /// Observable自動解放
    let disposeBag = DisposeBag()
    
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
        
        onceExec.call {
            // iPhoneX対応を入れたいので、Lauout時にセットアップする
            setup()
        }
    }

    private func setup() {

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
        
        // ヘルプ表示監視
        viewModel.rx_baseViewControllerViewModelDidPresentHelp
            .subscribe { [weak self] object in
                guard let `self` = self else { return }
                if let element = object.element {
                    let vc = HelpViewController(subtitle: element.subtitle, message: element.message)
                    self.present(vc, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
        
        splash = SplashViewController()
        splash!.view.frame.size = view.frame.size
        splash!.view.frame.origin = CGPoint.zero
        
        // スプラッシュ終了監視
        splash!.rx_splashViewControllerDidEndDrawing
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                if let splash = self.splash {
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
            .disposed(by: rx.disposeBag)
        
        view.addSubview(splash!.view)
        
        // ページ情報初期化
        PageHistoryDataModel.s.initialize()
        
        // レイヤー構造にしたいので、self.viewに対してaddSubViewする(self.view = baseLayerとしない)
        baseLayer = BaseLayer(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size))
        
        // ベースレイヤー無効化監視
        baseLayer.rx_baseLayerDidInvalidate
            .subscribe{ [weak self] object in
                guard let `self` = self else { return }
                if let direction = object.element {
                    self.frontLayer = FrontLayer(frame: self.baseLayer.frame, swipeDirection: direction)
                    self.frontLayer.rx_frontLayerDidInvalidate
                        .subscribe({ [weak self] _ in
                            guard let `self` = self else { return }
                            self.frontLayer.removeFromSuperview()
                            self.frontLayer = nil
                            self.baseLayer.validateUserInteraction()
                        })
                        .disposed(by: self.rx.disposeBag)
                    self.view.addSubview(self.frontLayer)
                }
            }
            .disposed(by: rx.disposeBag)
        
        view.addSubview(baseLayer)
        
        view.bringSubview(toFront: splash!.view)
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
                        viewModel.insertByEventPageHistoryDataModel(url: url)
                        return
                    }
                }
            }
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
