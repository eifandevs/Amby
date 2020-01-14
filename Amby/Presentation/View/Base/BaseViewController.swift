//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
import MessageUI
import Model
import Report
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
        if presentedViewController != nil {
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
            splash = SplashViewController()
            splash!.view.frame.size = view.frame.size
            splash!.view.frame.origin = CGPoint.zero

            // スプラッシュ終了監視
            splash!.rx_action
                .observeOn(MainScheduler.asyncInstance) // アニメーションさせるのでメインスレッドで実行
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element, let splash = self.splash, case .endDrawing = action else { return }
                    self.setup()
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
                .disposed(by: rx.disposeBag)

            view.addSubview(splash!.view)
        }
    }

    deinit {
        log.debug("deinit called.")
    }

    private func setup() {
        // タブデータ復元
        viewModel.initializeTab()

        // iPhoneX対応
        let insets = view.safeAreaInsets
        AppConst.BASE_LAYER.HEADER_HEIGHT = AppConst.BASE_LAYER.THUMBNAIL_SIZE.height * 1.1 + insets.top
        AppConst.BASE_LAYER.HEADER_FIELD_HEIGHT = (AppConst.BASE_LAYER.HEADER_HEIGHT / 2) - (insets.top / 3)
        AppConst.BASE_LAYER.HEADER_PROGRESS_MARGIN = AppConst.BASE_LAYER.HEADER_PROGRESS_BAR_HEIGHT * 2.2
        AppConst.BASE_LAYER.FOOTER_HEIGHT = AppConst.BASE_LAYER.THUMBNAIL_SIZE.height + insets.bottom
        AppConst.BASE_LAYER.BASE_HEIGHT = AppConst.DEVICE.DISPLAY_SIZE.height - AppConst.BASE_LAYER.FOOTER_HEIGHT - AppConst.BASE_LAYER.HEADER_HEIGHT

        // アクション監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }

                switch action {
                case let .help(title, message): self.help(title: title, message: message)
                case .openSource: self.openSource()
                case .report: self.report()
                case let .memo(memo): self.memo(memo: memo)
                case .menuOrder: self.menuOrder()
                case .passcode: self.passcode()
                case .passcodeConfirm: self.passcodeConfirm()
                case let .formReader(form): self.formReader(form: form)
                case .mailer: self.mailer()
                case let .notice(message, isSuccess): self.notice(message: message, isSuccess: isSuccess)
                case let .tabGroupTitle(groupContext): self.tabGroupTitle(groupContext: groupContext)
                case .sync: self.sync()
                case let .loginRequest(uid): self.loginRequest(uid: uid)
                }
            }
            .disposed(by: rx.disposeBag)

        // レイヤー構造にしたいので、self.viewに対してaddSubViewする(self.view = baseLayerとしない)
        baseLayer = BaseLayer(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: view.bounds.size))

        // ベースレイヤー無効化監視
        baseLayer!.rx_action
            .subscribe { [weak self] action in
                log.eventIn(chain: "baseLayer.rx_action")
                guard let `self` = self, let action = action.element, case let .invalidate(swipeDirection) = action else { return }
                self.frontLayer = FrontLayer(frame: self.baseLayer!.frame, swipeDirection: swipeDirection)
                self.frontLayer!.rx_action
                    .subscribe({ [weak self] action in
                        log.eventIn(chain: "frontLayer.rx_action")
                        guard let `self` = self, let action = action.element, case .invalidate = action else { return }
                        self.frontLayer!.removeFromSuperview()
                        self.frontLayer = nil
                        self.baseLayer!.validateUserInteraction()
                        log.eventOut(chain: "frontLayer.rx_action")
                    })
                    .disposed(by: self.rx.disposeBag)
                self.view.addSubview(self.frontLayer!)
                log.eventOut(chain: "baseLayer.rx_action")
            }
            .disposed(by: rx.disposeBag)

        view.addSubview(baseLayer!)

        if let splash = splash {
            view.bringSubview(toFront: splash.view)
        }
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

    // MARK: Private Method

    /// グループタイトル編集
    private func tabGroupTitle(groupContext: String) {
        CustomDialogService.presentTextFieldAlert(title: MessageConst.ALERT.CHANGE_GROUP_TITLE, message: "", placeholder: MessageConst.ALERT.CHANGE_GROUP_TITLE_PLACEHOLDER) { text in
            self.viewModel.changeGroupTitle(groupContext: groupContext, title: text)
        }
    }

    /// 通知表示
    private func notice(message: String, isSuccess: Bool) {
        NotificationService.presentToastNotification(message: message, isSuccess: isSuccess)
    }

    /// メーラー画面表示
    private func mailer() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([AppConst.MAIL.ADDRESS])
            mail.setSubject(AppConst.MAIL.SUBJECT)
            mail.setMessageBody(AppConst.MAIL.MESSAGE, isHTML: false)
            present(mail, animated: true)
        } else {
            log.error("cannot send mail.")
        }
    }

    /// フォーム閲覧画面表示
    private func formReader(form: Form) {
        let vc = FormViewController(form: form)
        present(vc, animated: true)
    }

    /// パスコード確認画面表示
    private func passcodeConfirm() {
        let vc = PasscodeViewController(isConfirm: true)
        present(vc, animated: true)
    }

    /// パスコード画面表示
    private func passcode() {
        let vc = PasscodeViewController(isConfirm: false)
        present(vc, animated: true)
    }

    /// メニュー順序表示
    private func menuOrder() {
        let vc = MenuOrderViewController()
        present(vc, animated: true)
    }

    /// ログイン画面表示
    private func sync() {
        let vc = SyncViewController()
        present(vc, animated: true)
    }

    /// ログインリクエスト
    private func loginRequest(uid: String) {
        log.debug("login request. uid: \(uid)")
        IndicatorService.s.showCircleIndicator()

        Observable.of(
            viewModel.login(uid: uid),
            viewModel.postMemo()
        ).concat().subscribe(onNext: nil, onError: { _ in
            log.debug("error login sequence")
            IndicatorService.s.dismissCircleIndicator()
//            NotificationService.presentToastNotification(message: MessageConst.ALERT.COMMON_MESSAGE, isSuccess: false)
            LogoutUseCase().exe()
        }, onCompleted: {
            log.debug("success login sequence")
//            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_SUCCESS, isSuccess: true)
            IndicatorService.s.dismissCircleIndicator()
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.reload()
            }
        }, onDisposed: nil)
            .disposed(by: rx.disposeBag)
    }

    /// メモ画面表示
    private func memo(memo: Memo) {
        let vc = MemoViewController(memo: memo)
        present(vc, animated: true)
    }

    /// レポート画面表示
    private func report() {
        let vc = ChatViewController()
        present(vc, animated: true)
    }

    /// ヘルプ画面表示
    private func help(title: String, message: String) {
        let vc = HelpViewController(subtitle: title, message: message)
        present(vc, animated: true)
    }

    /// オープンソース表示
    private func openSource() {
        let vc = OpenSourceViewController()
        present(vc, animated: true)
    }

    // MARK: WebView Touch

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if Bundle(for: type(of: viewControllerToPresent)).bundleIdentifier == "com.apple.WebKit" {
            if let orgActionSheet = viewControllerToPresent as? UIAlertController, let url = orgActionSheet.title {
                if (orgActionSheet.preferredStyle == .actionSheet) && (orgActionSheet.title != nil) {
                    // webviewを長押しされたら、そのURLで新しいタブを作成する
                    if url.isValidUrl {
                        viewModel.insertTab(url: url)
                        return
                    }
                }
            }
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension BaseViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error _: Error?) {
        switch result {
        case .cancelled:
            log.debug("キャンセル")
        case .saved:
            log.debug("下書き保存")
        case .sent:
            log.debug("送信成功")
        default:
            log.debug("送信失敗")
        }
        dismiss(animated: true, completion: nil)
    }
}
