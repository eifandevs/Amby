//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class BaseViewController: UIViewController {
    private var baseLayer: BaseLayer?
    private var frontLayer: FrontLayer?
    private let viewModel = BaseViewControllerViewModel()

    private var splash: SplashViewController?

    // 全面に画面がpresentされているか
    var isPresented: Bool {
        if self.presentedViewController != nil {
            return true
        }

        return false
    }

    /// 初回実行用
    private var onceExec = OnceExec()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    deinit {
        log.debug("deinit called.")
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
                let width = UIScreen.main.bounds.size.width / 4.3
                let height = (UIScreen.main.bounds.size.width / 3.4) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
                AppConst.BASE_LAYER_THUMBNAIL_SIZE = CGSize(width: width, height: height)
            } else {
                AppConst.BASE_LAYER_HEADER_HEIGHT = AppConst.BASE_LAYER_THUMBNAIL_SIZE.height * 1.3
                AppConst.BASE_LAYER_HEADER_PROGRESS_MARGIN = AppConst.BASE_LAYER_HEADER_PROGRESS_BAR_HEIGHT
                AppConst.BASE_LAYER_FOOTER_HEIGHT = AppConst.BASE_LAYER_THUMBNAIL_SIZE.height
                AppConst.BASE_LAYER_HEADER_FIELD_HEIGHT = AppConst.BASE_LAYER_HEADER_HEIGHT / 2
                let width = UIScreen.main.bounds.size.width / 4.3
                let height = (UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
                AppConst.BASE_LAYER_THUMBNAIL_SIZE = CGSize(width: width, height: height)
            }
        }

        // ヘルプ表示監視
        viewModel.rx_baseViewControllerViewModelDidPresentHelp
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewControllerViewModelDidPresentHelp")
                guard let `self` = self else { return }
                if let element = object.element {
                    let vc = HelpViewController(subtitle: element.subtitle, message: element.message)
                    self.present(vc, animated: true)
                }
                log.eventOut(chain: "rx_baseViewControllerViewModelDidPresentHelp")
            }
            .disposed(by: rx.disposeBag)

        splash = SplashViewController()
        splash!.view.frame.size = view.frame.size
        splash!.view.frame.origin = CGPoint.zero

        // スプラッシュ終了監視
        splash!.rx_splashViewControllerDidEndDrawing
            .observeOn(MainScheduler.asyncInstance) // アニメーションさせるのでメインスレッドで実行
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_splashViewControllerDidEndDrawing")
                guard let `self` = self else { return }
                if let splash = self.splash {
                    UIView.animate(withDuration: 0.3, animations: {
                        splash.view.alpha = 0
                    }, completion: { finished in
                        if finished {
                            splash.view.removeFromSuperview()
                            splash.removeFromParentViewController()
                            self.splash = nil
                        }
                    })
                }
                log.eventOut(chain: "rx_splashViewControllerDidEndDrawing")
            }
            .disposed(by: rx.disposeBag)

        view.addSubview(splash!.view)

        // ページ情報初期化
        PageHistoryDataModel.s.initialize()

        // レイヤー構造にしたいので、self.viewに対してaddSubViewする(self.view = baseLayerとしない)
        baseLayer = BaseLayer(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: view.bounds.size))

        // ベースレイヤー無効化監視
        baseLayer!.rx_baseLayerDidInvalidate
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseLayerDidInvalidate")
                guard let `self` = self else { return }
                if let direction = object.element {
                    self.frontLayer = FrontLayer(frame: self.baseLayer!.frame, swipeDirection: direction)
                    self.frontLayer!.rx_frontLayerDidInvalidate
                        .subscribe({ [weak self] _ in
                            log.eventIn(chain: "rx_frontLayerDidInvalidate")
                            guard let `self` = self else { return }
                            self.frontLayer!.removeFromSuperview()
                            self.frontLayer = nil
                            self.baseLayer!.validateUserInteraction()
                            log.eventOut(chain: "rx_frontLayerDidInvalidate")
                        })
                        .disposed(by: self.rx.disposeBag)
                    self.view.addSubview(self.frontLayer!)
                }
                log.eventOut(chain: "rx_baseLayerDidInvalidate")
            }
            .disposed(by: rx.disposeBag)

        view.addSubview(baseLayer!)

        view.bringSubview(toFront: splash!.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 解放処理
    func mRelease() {
        // 何故かマニュアルで解放しないとdeinitが呼ばれない
        if baseLayer != nil {
            baseLayer!.mRelease()
            baseLayer!.removeFromSuperview()
            baseLayer = nil
        }

        if frontLayer != nil {
            frontLayer!.mRelease()
            frontLayer!.removeFromSuperview()
            frontLayer = nil
        }

        if splash != nil {
            splash!.view.removeFromSuperview()
            splash!.removeFromParentViewController()
            splash = nil
        }
    }

    // MARK: WebView Touch

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if Bundle(for: type(of: viewControllerToPresent)).bundleIdentifier == "com.apple.WebKit" {
            if let orgActionSheet = viewControllerToPresent as? UIAlertController, let url = orgActionSheet.title {
                if (orgActionSheet.preferredStyle == .actionSheet) && (orgActionSheet.title != nil) {
                    // webviewを長押しされたら、そのURLで新しいタブを作成する
                    if url.isValidUrl {
                        viewModel.insertByEventPageHistoryDataModel(url: url)
                        return
                    }
                }
            }
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
