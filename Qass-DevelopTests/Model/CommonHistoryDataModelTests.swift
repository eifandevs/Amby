//
//  CommonHistoryDataModelTests.swift
//  QassTests
//
//  Created by tenma on 2018/03/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class CommonHistoryDataModelTests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        PageHistoryDataModel.s.delete()
        CommonHistoryDataModel.s.delete()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGoBack() {
        weak var expectation = self.expectation(description: "goBack")

        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoBack
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        CommonHistoryDataModel.s.goBack()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoForward() {
        weak var expectation = self.expectation(description: "goForward")

        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoForward
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        CommonHistoryDataModel.s.goForward()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInsert() {
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function)
        XCTAssertTrue(CommonHistoryDataModel.s.histories.first!.title == #function)
        XCTAssertTrue(CommonHistoryDataModel.s.histories.first!.url == "https://abc/")
    }

    func testStore() {
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function)
        CommonHistoryDataModel.s.store()
        let storedHistory = CommonHistoryDataModel.s.select(title: #function, readNum: 10).first!
        XCTAssertTrue(storedHistory.title == #function)
        XCTAssertTrue(storedHistory.url == "https://abc/")
    }

    func testGetList() {
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function)
        CommonHistoryDataModel.s.store()
        let list = CommonHistoryDataModel.s.getList()
        XCTAssertTrue(list.first! == Date().toString())
    }

    func testSelect() {
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function)
        CommonHistoryDataModel.s.store()
        let storedHistory = CommonHistoryDataModel.s.select(dateString: Date().toString()).first!
        XCTAssertTrue(storedHistory.title == #function)
        XCTAssertTrue(storedHistory.url == "https://abc/")
    }

    func testSelectWithTitle() {
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function)
        CommonHistoryDataModel.s.store()
        let storedHistory = CommonHistoryDataModel.s.select(title: #function, readNum: 10).first!
        XCTAssertTrue(storedHistory.title == #function)
        XCTAssertTrue(storedHistory.url == "https://abc/")
    }

    func testExpireCheck() {
        let calendar = Calendar.current
        let date = Date()

        let historySaveCount = UserDefaultRepository().commonHistorySaveCount
        (0...historySaveCount).forEach {
            let expiredDate = calendar.date(byAdding: .day, value: -($0 + 1), to: calendar.startOfDay(for: date))!

            CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function, date: expiredDate)
            CommonHistoryDataModel.s.store()
        }

        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == historySaveCount + 1)

        CommonHistoryDataModel.s.expireCheck()

        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == historySaveCount)
    }

    func testDeleteWithIds() {
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function)
        let storedId = CommonHistoryDataModel.s.histories.first!._id

        CommonHistoryDataModel.s.store()
        CommonHistoryDataModel.s.delete(historyIds: [Date().toString(): [storedId]])

        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == 0)
    }

    func testDelete() {
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc/"), title: #function)
        CommonHistoryDataModel.s.store()
        CommonHistoryDataModel.s.delete()

        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == 0)
        XCTAssertTrue(CommonHistoryDataModel.s.histories.count == 0)
    }
}
