//
//  CommonHistoryDataModelTests.swift
//  Qas-DevelopTests
//
//  Created by tenma on 2018/03/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qas_Develop

class CommonHistoryDataModelTests: XCTestCase {
    
    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        CommonHistoryDataModel.s.delete()
        CommonHistoryDataModel.s.initialize()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        CommonHistoryDataModel.s.delete()
        CommonHistoryDataModel.s.initialize()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
        let history = CommonHistory(url: "testInsert", title: "testInsert", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        XCTAssertTrue(CommonHistoryDataModel.s.histories.first!.title == "testInsert")
        XCTAssertTrue(CommonHistoryDataModel.s.histories.first!.url == "testInsert")
    }
    
    func testStore() {
        let history = CommonHistory(url: "testStore", title: "testStore", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        CommonHistoryDataModel.s.store()
        let storedHistory = CommonHistoryDataModel.s.select(title: "testStore", readNum: 10).first!
        XCTAssertTrue(storedHistory.title == "testStore")
        XCTAssertTrue(storedHistory.url == "testStore")
    }
    
    func testInitialize() {
        let history = CommonHistory(url: "testInsert", title: "testInsert", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        CommonHistoryDataModel.s.initialize()
        XCTAssertTrue(CommonHistoryDataModel.s.histories.count == 0)
    }
    
    func testGetList() {
        let history = CommonHistory(url: "testGetList", title: "testGetList", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        CommonHistoryDataModel.s.store()
        let list = CommonHistoryDataModel.s.getList()
        XCTAssertTrue(list.first! == Date().toString())
    }
    
    func testSelect() {
        let history = CommonHistory(url: "testSelect", title: "testSelect", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        CommonHistoryDataModel.s.store()
        let storedHistory = CommonHistoryDataModel.s.select(dateString: Date().toString()).first!
        XCTAssertTrue(history.title == storedHistory.title)
        XCTAssertTrue(history.url == storedHistory.url)
    }
    
    func testSelectWithTitle() {
        let history = CommonHistory(url: "testSelect", title: "testSelect", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        CommonHistoryDataModel.s.store()
        let storedHistory = CommonHistoryDataModel.s.select(title: "testSelect", readNum: 10).first!
        XCTAssertTrue(history.title == storedHistory.title)
        XCTAssertTrue(history.url == storedHistory.url)
    }
    
    func testExpireCheck() {
        let calendar = Calendar.current
        let date = Date()
        
        let historySaveCount = Int(UserDefaults.standard.integer(forKey: AppConst.KEY_COMMON_HISTORY_SAVE_COUNT))
        (0...historySaveCount).forEach {
            let expiredDate = calendar.date(byAdding: .day, value: -($0 + 1), to: calendar.startOfDay(for: date))!
            
            let history = CommonHistory(url: "testSelect", title: "testSelect", date: expiredDate)
            CommonHistoryDataModel.s.insert(history: history)
            CommonHistoryDataModel.s.store()
        }
        
        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == historySaveCount + 1)

        CommonHistoryDataModel.s.expireCheck()
        
        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == historySaveCount)
    }
    
    func testDeleteWithIds() {
        let history = CommonHistory(url: "testStore", title: "testStore", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        CommonHistoryDataModel.s.store()
        CommonHistoryDataModel.s.delete(historyIds: [Date().toString(): [history._id]])
        
        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == 0)
    }
    
    func testDelete() {
        let history = CommonHistory(url: "testStore", title: "testStore", date: Date())
        CommonHistoryDataModel.s.insert(history: history)
        CommonHistoryDataModel.s.store()
        CommonHistoryDataModel.s.delete()
        
        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == 0)
        XCTAssertTrue(CommonHistoryDataModel.s.histories.count == 0)
    }
}
