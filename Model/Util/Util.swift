//
//  Util.swift
//  Model
//
//  Created by tenma on 2018/09/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import CommonUtil
import Foundation
import UIKit

/// 共通ユーティリティクラス

class Util {
    /// フォアグラウンドビューコントローラー取得
    static func foregroundViewController() -> UIViewController {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while (vc!.presentedViewController) != nil {
            vc = vc!.presentedViewController
        }
        return vc!
    }

    /// フォルダー作成
    static func createFolder(path: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            return true
        } else {
            if !isDir.boolValue {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    log.debug("create directory. path: \(path)")
                    return true
                } catch let error as NSError {
                    log.error("create directory error. error: \(error.localizedDescription)")
                }
            }
        }

        return false
    }

    /// フォルダー削除
    static func deleteFolder(path: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            do {
                try fileManager.removeItem(atPath: path)
                return true
            } catch let error as NSError {
                log.error("remove item error. error: \(error.localizedDescription)")
            }
        } else {
            log.error("remove item already removed.")
        }

        return false
    }

    /// ファーストレスポンダー取得
    static func findFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        for subview in view.subviews {
            if subview.isFirstResponder {
                return subview
            }
            let responder = findFirstResponder(view: subview)
            if let responder = responder {
                return responder
            }
        }
        return nil
    }

    /// キーボードが表示されているか
    static func displayedKeyboard() -> Bool {
        let window: UIWindow? = {
            for w in UIApplication.shared.windows where w.className == "UIRemoteKeyboardWindow" {
                return w
            }
            return nil
        }()
        if window != nil {
            return true
        } else {
            return false
        }
    }
}

// MARK: - グローバル定義

/// rxswift用
public func void<T>(_: T) {}

// MARK: - 演算子拡張

func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

func / (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
}

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

// swiftlint:disable shorthand_operator
func *= (left: inout CGSize, right: CGSize) {
    left = left * right
}

func *= (left: inout CGSize, right: CGFloat) {
    left = left * right
}

func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}

func *= (left: inout CGPoint, right: CGFloat) {
    left = left * right
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}
// swiftlint:enable shorthand_operator
