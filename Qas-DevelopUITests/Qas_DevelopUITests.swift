//
//  Qas_DevelopUITests.swift
//  Qas-DevelopUITests
//
//  Created by tenma on 2018/04/03.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest

@testable import Qas_Develop

class Qas_DevelopUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        sleep(5)
        if app.keyboards.count > 0 {
            app.keys["A"].tap()
            app.keys["a"].tap()
            app.keys["a"].tap()
            
            // 検索してくるくるがいなくなるまで10秒間処理を中断する
            let indicator = app.otherElements["NVActivityIndicatorView.NVActivityIndicatorView"]
            let notExists = NSPredicate(format: "exists == false")
            expectation(for: notExists, evaluatedWith: indicator, handler: { () -> Bool in
                print("search loading finish.")
                return true
            })
            // 検索タップ
            app.buttons["Search"].tap()
            sleep(5)
            waitForExpectations(timeout: 10, handler: nil)

            // 初回google検索結果表示時は、言語設定のモーダルが表示されるので、タップして削除する
            let launguageLink = app.links.element(boundBy: 1)
            launguageLink.tap()
        }
        sleep(2)
        // 検索してくるくるがいなくなるまで10秒間処理を中断する
        let indicator = app.otherElements["NVActivityIndicatorView.NVActivityIndicatorView"]
        let notExists = NSPredicate(format: "exists == false")
        expectation(for: notExists, evaluatedWith: indicator, handler: { () -> Bool in
            print("link loading finish.")
            return true
        })
        // 適当にリンクタップ
        app.links.element(boundBy: 30).tap()
        sleep(5)
        waitForExpectations(timeout: 10, handler: nil)

        // 左エッジスワイプ
        let coord1: XCUICoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.15))
        let coord2 = coord1.withOffset(CGVector(dx: 40, dy: 100))

        coord1.press(forDuration: 0.1, thenDragTo: coord2)
        sleep(6)
    }
    
}
