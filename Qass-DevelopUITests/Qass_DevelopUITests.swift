//
//  Qass_DevelopUITests.swift
//  Qass-DevelopUITests
//
//  Created by tenma on 2018/04/03.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import UIKit

@testable import Qass_Develop

class Qass_DevelopUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        Springboard.deleteMyApp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        app = XCUIApplication()
        sleep(4)

        // キーボードの表示を確認
        XCTAssertTrue(app.keyboards.count > 0)

        // ----- 検索 -----
        app.keys["A"].tap()
        app.buttons["Search"].tap()
        waitLoading()
        // 初回google検索結果表示時は、言語設定のモーダルが表示されるので、タップして削除する
        let launguageLink = app.links.element(boundBy: 1)
        launguageLink.tap()
        sleep(1)

        // ----- 適当にリンクタップ -----
        app.links.element(boundBy: 30).tap()
        waitLoading()

        // ----- ヒストリーバック -----
        let coord1: XCUICoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coord2 = coord1.withOffset(CGVector(dx: coord1.screenPoint.x + 40, dy: 0))
        coord1.press(forDuration: 0.1, thenDragTo: coord2)
        waitLoading()

        // ----- ヒストリーフォワード -----
        let coord3: XCUICoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0))
        let coord4 = coord3.withOffset(CGVector(dx: 0.99, dy: 0))
        coord3.press(forDuration: 0.1, thenDragTo: coord4)
    }

    private func waitLoading() {
        sleep(1)
        // 検索してくるくるがいなくなるのを検知
        let indicator = app.otherElements["NVActivityIndicatorView.NVActivityIndicatorView"]
        let notExists = NSPredicate(format: "exists == false")
        expectation(for: notExists, evaluatedWith: indicator, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        sleep(1)
    }

}
