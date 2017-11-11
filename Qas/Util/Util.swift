//
//  Util.swift
//  Eiger
//
//  Created by temma on 2017/02/14.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

/// 共通ユーティリティクラス

class Util {
    /// フォアグラウンドビューコントローラー取得
    static func foregroundViewController() -> UIViewController {
        var vc = UIApplication.shared.keyWindow?.rootViewController;
        while ((vc!.presentedViewController) != nil) {
            vc = vc!.presentedViewController;
        }
        return vc!;
    }
    
    /// フォルダー削除
    static func createFolder(path: String) {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            try! fileManager.createDirectory(atPath: path ,withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// フォルダー削除
    static func deleteFolder(path: String) {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            try! fileManager.removeItem(atPath: path)
        }
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
            for w in UIApplication.shared.windows {
                if w.className == "UIRemoteKeyboardWindow" {
                    return w
                }
            }
            return nil
        }()
        if window != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - フォルダパス
    /// サムネイルフォルダ
    static func thumbnailFolderPath(folder: String) -> String {
        let path = AppConst.PATH_THUMBNAIL + "/\(folder)"
        Util.createFolder(path: path)
        return path
    }
    
    /// サムネイルフォルダ(URL)
    static func thumbnailFolderUrl(folder: String) -> URL {
        let path = DeviceConst.CACHES_PATH + "/thumbnails/\(folder)"
        return URL(fileURLWithPath: path)
    }
    
    /// サムネイル画像
    static func thumbnailPath(folder: String) -> String {
        let path = AppConst.PATH_THUMBNAIL + "/\(folder)"
        Util.createFolder(path: path)
        return path + "/thumbnail.png"
    }
    
    /// サムネイル画像(URL)
    static func thumbnailUrl(folder: String) -> URL {
        let path = AppConst.PATH_THUMBNAIL + "/\(folder)"
        Util.createFolder(path: path)
        return URL(fileURLWithPath: path + "/thumbnail.png")
    }
    
    /// 閲覧履歴
    static func commonHistoryPath(date: String) -> String {
        return AppConst.PATH_COMMON_HISTORY + "/\(date).dat"
    }
    
    /// 閲覧履歴(URL)
    static func commonHistoryUrl(date: String) -> URL {
        let path = AppConst.PATH_COMMON_HISTORY
        Util.createFolder(path: path)
        return URL(fileURLWithPath: path + "/\(date).dat")
    }
    
    /// 検索履歴
    static func searchHistoryPath(date: String) -> String {
        return AppConst.PATH_SEARCH_HISTORY + "/\(date).dat"
    }
    
    /// 検索履歴(URL)
    static func searchHistoryUrl(date: String) -> URL {
        let path = AppConst.PATH_SEARCH_HISTORY
        Util.createFolder(path: path)
        return URL(fileURLWithPath: path + "/\(date).dat")
    }
}

// MARK: -  演算子拡張

func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

func /(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
}

func +(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func -(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func *(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
    
}

func *(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

func *= ( left: inout CGSize, right: CGSize) {
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
