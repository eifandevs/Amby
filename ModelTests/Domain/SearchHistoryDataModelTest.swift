//
//  SearchHistoryDataModelTest.swift
//  ModelTests
//
//  Created by iori tenma on 2019/04/20.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model
@testable import Entity

class SearchHistoryDataModelTest: XCTestCase {

    let disposeBag = DisposeBag()

    let dummyText = "dummy"
    let dummyText2 = "dummy2"

    var searchHistoryDataModel: SearchHistoryDataModelProtocol {
        return SearchHistoryDataModel.s
    }

    var todayString: String {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: "ja_JP")
        formatter.locale = jaLocale
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }

    // 過去何日分かの日付を取得
    func dateWithCount(beforeCount: Int) -> [Date] {
        guard beforeCount > 0 else { fatalError() }
        return (1...beforeCount).map { Date(timeIntervalSinceNow: Double($0) * -1 * 60 * 60 * 24) }
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        searchHistoryDataModel.delete()
    }

    func testGetList() {
        searchHistoryDataModel.store(text: dummyText)
        let list = searchHistoryDataModel.getList()
        XCTAssertTrue(list.first! == todayString)
    }

    func testStore() {
        searchHistoryDataModel.store(text: dummyText)
    }

    func testStoreWithHistories() {
        let data = SearchHistory(title: dummyText, date: Date())
        let data2 = SearchHistory(title: dummyText2, date: Date().yesterday)
        searchHistoryDataModel.store(histories: [data, data2])
        let list = searchHistoryDataModel.getList()
        XCTAssertTrue(list.count == 2)
    }

    func testSelectWithDuplication() {
        let data = SearchHistory(title: dummyText, date: Date())
        let data2 = SearchHistory(title: dummyText, date: Date().yesterday)
        searchHistoryDataModel.store(histories: [data, data2])
        let result = searchHistoryDataModel.select(title: dummyText, readNum: 10)
        XCTAssertTrue(result.count == 1)
        XCTAssertTrue(result.first!.title == dummyText)
    }

    func testSelectAsc() {
        let data = SearchHistory(title: dummyText, date: Date())
        let data2 = SearchHistory(title: dummyText2, date: Date().yesterday)
        searchHistoryDataModel.store(histories: [data, data2])
        let result = searchHistoryDataModel.select(title: dummyText, readNum: 10)
        XCTAssertTrue(result.count == 2)
        XCTAssertTrue(result.first!.title == dummyText2)
    }

    func testSelectDesc() {
        let data = SearchHistory(title: dummyText2, date: Date())
        let data2 = SearchHistory(title: dummyText, date: Date().yesterday)
        searchHistoryDataModel.store(histories: [data, data2])
        let result = searchHistoryDataModel.select(title: dummyText, readNum: 10)
        XCTAssertTrue(result.count == 2)
        XCTAssertTrue(result.first!.title == dummyText)
    }

    func testExpireCheck() {
        searchHistoryDataModel.store(histories: dateWithCount(beforeCount: 100).map { SearchHistory(title: dummyText2, date: $0) })
        searchHistoryDataModel.expireCheck()
        let list = searchHistoryDataModel.getList()
        XCTAssertTrue(list.count == 90)
    }

    func testDelete() {
        let data = SearchHistory(title: dummyText, date: Date())
        let data2 = SearchHistory(title: dummyText2, date: Date().yesterday)
        searchHistoryDataModel.store(histories: [data, data2])

        weak var expectation = self.expectation(description: #function)

        searchHistoryDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .deleteAll = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        searchHistoryDataModel.delete()

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
