//
//  CommonHistoryDataModelTest.swift
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

class CommonHistoryDataModelTest: XCTestCase {

    let disposeBag = DisposeBag()

    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

    var todayString: String {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: "ja_JP")
        formatter.locale = jaLocale
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }

    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date().noon)!
    }

    var commonHistoryDataModel: CommonHistoryDataModelProtocol {
        return CommonHistoryDataModel.s
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        commonHistoryDataModel.delete()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle)
    }

    func testGetHistory() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle)
        let history = commonHistoryDataModel.getHistory(index: 0)
        XCTAssertTrue(history!.url == dummyUrl)
    }

    func testStore() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle)
        commonHistoryDataModel.store()
        XCTAssertTrue(commonHistoryDataModel.histories.count == 0)
    }

    func testGetList() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle)
        commonHistoryDataModel.store()
        let list = commonHistoryDataModel.getList()
        XCTAssertTrue(list.count == 1)
        XCTAssertTrue(list.first! == todayString)
    }

    func testSelect() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle)
        commonHistoryDataModel.store()
        let history = commonHistoryDataModel.select(dateString: todayString)
        XCTAssertTrue(history.first!.url == dummyUrl)
    }

    func testSelectWithTitle() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle)
        commonHistoryDataModel.store()
        let history = commonHistoryDataModel.select(title: dummyTitle, readNum: 10)
        XCTAssertTrue(history.first!.title == dummyTitle)
    }

    func testExpireCheck() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle, date: Date())
        commonHistoryDataModel.insert(url: URL(string: dummyUrl2), title: dummyTitle2, date: yesterday)
        commonHistoryDataModel.store()
        let before = commonHistoryDataModel.getList()
        XCTAssertTrue(before.count == 2)
        commonHistoryDataModel.expireCheck(historySaveCount: 1)
        let after = commonHistoryDataModel.getList()
        XCTAssertTrue(after.count == 1)
    }

    func testDeleteWithId() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle, date: Date())
        commonHistoryDataModel.insert(url: URL(string: dummyUrl2), title: dummyTitle2, date: yesterday)
        commonHistoryDataModel.store()
        let history = commonHistoryDataModel.select(dateString: todayString).first!
        commonHistoryDataModel.delete(historyIds: [todayString: [history._id]])
        XCTAssertTrue(commonHistoryDataModel.select(dateString: todayString).count == 0)
    }

    func testDelete() {
        commonHistoryDataModel.insert(url: URL(string: dummyUrl), title: dummyTitle, date: Date())
        commonHistoryDataModel.insert(url: URL(string: dummyUrl2), title: dummyTitle2, date: yesterday)
        commonHistoryDataModel.store()
        commonHistoryDataModel.delete()
    }
}
