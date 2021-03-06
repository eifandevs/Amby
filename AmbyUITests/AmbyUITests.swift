//
//  AmbyUITests.swift
//  AmbyUITests
//
//  Created by iori tenma on 2019/05/02.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import XCTest

class AmbyUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Springboard.deleteMyApp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScenario() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        app = XCUIApplication()

        // キーボードの表示を待つ
        waitExist(element: app.keyboards.firstMatch)
        XCTAssertTrue(app.keys["A"].exists) // 英語キーボードのみ

        // ----- 検索 -----
        do {
            app.keys["W"].tap()
            app.keys["e"].tap()
            app.keys["l"].tap()
            app.keys["c"].tap()
            app.keys["o"].tap()
            app.keys["m"].tap()
            app.keys["space"].tap()
            app.keys["t"].tap()
            app.keys["o"].tap()
            app.keys["space"].tap()
            app.keys["p"].tap()
            app.keys["r"].tap()
            app.keys["i"].tap()
            app.keys["m"].tap()
            app.keys["e"].tap()
            app.buttons["Search"].tap()

            // 初回google検索結果表示時は、言語設定のモーダルが表示されるので、それを待つ
            sleep(5)
            if app.links["Change to English"].exists {
                app.links["Change to English"].tap()
            }

            waitExist(element: app.links["Prime Video"])

            // ----- 適当にリンクタップ -----
            app.links["Prime Video"].tap()
            waitExist(element: app.links["Help"])
        }

        // ----- ヒストリーバック -----
        do {
            openMenu()
            app.buttons["circlemenu-historyback"].tap()
            if app.links["Change to English"].exists {
                app.links["Change to English"].tap()
            }
            waitExist(element: app.links["Welcome to Prime Video"])
        }

        // ----- ヒストリーフォワード -----
        do {
            openMenu()
            changeMenu()
            app.buttons["circlemenu-historyforward"].tap()
            waitExist(element: app.links["Help"])
        }

        // ----- メニュー -----
        do {
            openMenu()
            app.buttons["circlemenu-menu"].tap()
            let coord = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 1.5))
            coord.press(forDuration: 0.1)
        }

        // ----- コピー -----
        do {
            openMenu()
            app.buttons["circlemenu-copy"].tap()
            waitExist(element: app.links["Help"])
        }

        // ----- 削除 -----
        do {
            openMenu()
            app.buttons["circlemenu-close"].tap()
        }

        // ----- 検索 -----
        do {
            openMenu()
            app.buttons["circlemenu-add"].tap()

            // キーボードの表示を待つ
            waitExist(element: app.keyboards.firstMatch)
            XCTAssertTrue(app.keys["A"].exists) // 英語キーボードのみ

            app.keys["W"].tap()
            app.keys["e"].tap()
            app.keys["l"].tap()
            app.keys["c"].tap()
            app.keys["o"].tap()
            app.keys["m"].tap()
            app.keys["space"].tap()
            app.keys["t"].tap()
            app.keys["o"].tap()
            app.keys["space"].tap()
            app.keys["p"].tap()
            app.keys["r"].tap()
            app.keys["i"].tap()
            app.keys["m"].tap()
            app.keys["e"].tap()
            app.buttons["Search"].tap()

            waitExist(element: app.links["Prime Video"])
        }

        // ----- 自動スクロール -----
        do {
            openMenu()
            changeMenu()
            app.buttons["circlemenu-autoscroll"].tap()
            sleep(2)
            app.links["Prime Video"].tap()
            waitExist(element: app.links["Help"])
        }
    }

    private func changeMenu() {
        app.buttons["circlemenu"].tap()
    }

    private func openMenu() {
        let deviceName = getDeviceInfo()
        switch deviceName {
        case "iPhone":
            let coord1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 1.5))
            let coord2 = coord1.withOffset(CGVector(dx: 100, dy: 1.5))
            coord1.press(forDuration: 0.1, thenDragTo: coord2)
        case "iPhone Plus":
            let coord1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 2.3))
            let coord2 = coord1.withOffset(CGVector(dx: 140, dy: 2.3))
            coord1.press(forDuration: 0.1, thenDragTo: coord2)
        default:
            XCTAssertTrue(false)
        }
    }

    private func waitExist(element: XCUIElement) {
        let notExists = NSPredicate(format: "exists == true")
        expectation(for: notExists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }

    private func getDeviceInfo() -> String {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let result = CGSize(width: size.width * scale, height: size.height * scale)
        switch result.height {
        case 960:
            return "iPhone"
        case 1440:
            return "iPhone Plus"
        default:
            return "unknown"
        }
    }

}
