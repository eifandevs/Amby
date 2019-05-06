//
//  Springboard.swift
//  AmbyUITests
//
//  Created by iori tenma on 2019/05/02.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest

// 端末内のアプリを削除し、データもResetしてくれるクラス
final class Springboard {
    static let appDisplayName = "Amby"

    static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    static let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")

    /**
     Terminate and delete the app via springboard
     https://stackoverflow.com/questions/33107731/is-there-a-way-to-reset-the-app-between-tests-in-swift-xctest-ui-in-xcode-7/39092323#39092323
     */
    static func deleteMyApp() {
        guard self.isSimulator() else {
            // Simulatorじゃなかったらデータとか消えたらまずいので何もしない
            return
        }

        XCUIApplication().terminate()

        // Resolve the query for the springboard rather than launching it
        springboard.activate()

        // Rotate back to Portrait, just to ensure repeatability here
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        // Sleep to let the device finish its rotation animation, if it needed rotating
        sleep(2)

        // Force delete the app from the springboard
        // Handle iOS 11 iPad 'duplication' of icons (one nested under "Home screen icons" and the other nested under "Multitasking Dock"
        let icon = springboard.otherElements["Home screen icons"].scrollViews.otherElements.icons[self.appDisplayName]
        if icon.exists {
            let iconFrame = icon.frame
            let springboardFrame = springboard.frame
            icon.press(forDuration: 2.5)

            // Tap the little "X" button at approximately where it is. The X is not exposed directly
            springboard.coordinate(withNormalizedOffset: CGVector(dx: ((iconFrame.minX + 9) / springboardFrame.maxX), dy: ((iconFrame.minY + 9) / springboardFrame.maxY))).tap()
            // Wait some time for the animation end
            Thread.sleep(forTimeInterval: 1.5)

            //springboard.alerts.buttons["Delete"].firstMatch.tap()
            springboard.buttons["Delete"].firstMatch.tap()

            Thread.sleep(forTimeInterval: 0.5)

            // Press home once make the icons stop wiggling
            XCUIDevice.shared.press(.home)
            // Press home again to go to the first page of the springboard
            XCUIDevice.shared.press(.home)
            // Wait some time for the animation end
            Thread.sleep(forTimeInterval: 0.5)

            // Handle iOS 11 iPad 'duplication' of icons (one nested under "Home screen icons" and the other nested under "Multitasking Dock"
            let settingsIcon = springboard.otherElements["Home screen icons"].scrollViews.otherElements.icons["Settings"]
            if settingsIcon.exists {
                settingsIcon.tap()
                settings.tables.staticTexts["General"].tap()
                settings.tables.staticTexts["Reset"].tap()
                settings.tables.staticTexts["Reset Location & Privacy"].tap()
                // Handle iOS 11 iPad difference in error button text
                if UIDevice.current.userInterfaceIdiom == .pad {
                    settings.buttons["Reset"].tap()
                } else {
                    settings.buttons["Reset Warnings"].tap()
                }
                settings.terminate()
            }
        }
    }

    private static func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
