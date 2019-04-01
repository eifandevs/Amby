//
//  PageHistoryDataModelTests.swift
//  ModelTests
//
//  Created by tenma on 2019/04/01.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model

class PageHistoryDataModelTests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        PageHistoryDataModel.s.delete()
        PageHistoryDataModel.s.initialize()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialize() {
        PageHistoryDataModel.s.initialize()
        XCTAssertTrue(PageHistoryDataModel.s.histories.count == 1)
    }

    func testAppend() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .append(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(after.pageHistory.url == "https://abc/")
                        XCTAssertTrue(before!.pageHistory.url == "")
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: "https://abc/")

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChange() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .change(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(after.pageHistory.url == "https://abc/")
                        XCTAssertTrue(before.pageHistory.url == "https://def/")
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://def/")
        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
