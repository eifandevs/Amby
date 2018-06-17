//
//  SearchHistoryDataModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest

@testable import Qass_Develop

class SearchHistoryDataModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // local storage setup
        SearchHistoryDataModel.s.delete()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetList() {
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().yesterday)])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().yesterday)])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date())])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date())])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().tomorrow)])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().tomorrow)])
        
        SearchHistoryDataModel.s.store(histories: [
            SearchHistory(title: #function + "2", date: Date().yesterday),
            SearchHistory(title: #function + "2", date: Date().yesterday),
            SearchHistory(title: #function + "2", date: Date()),
            SearchHistory(title: #function + "2", date: Date()),
            SearchHistory(title: #function + "2", date: Date().tomorrow),
            SearchHistory(title: #function + "2", date: Date().tomorrow)
        ])
        
        XCTAssertTrue(SearchHistoryDataModel.s.getList().count == 3)
    }
    
    func testStore() {
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().yesterday)])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().yesterday)])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date())])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date())])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().tomorrow)])
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: Date().tomorrow)])

        SearchHistoryDataModel.s.store(histories: [
            SearchHistory(title: #function + "2", date: Date().yesterday),
            SearchHistory(title: #function + "2", date: Date().yesterday),
            SearchHistory(title: #function + "2", date: Date()),
            SearchHistory(title: #function + "2", date: Date()),
            SearchHistory(title: #function + "2", date: Date().tomorrow),
            SearchHistory(title: #function + "2", date: Date().tomorrow)
        ])

        XCTAssertTrue(SearchHistoryDataModel.s.select(title: #function, readNum: 5).count == 2)
    }
    
    func testExpireCheck() {
        let now = Date()
        (1...400).forEach { index in
            let ago = -index
            let date = Date(timeInterval: TimeInterval(-(60*60*24*ago + 100)), since: now)
            SearchHistoryDataModel.s.store(histories: [SearchHistory(title: #function, date: date)])
        }
        XCTAssertTrue(SearchHistoryDataModel.s.getList().count == 400)
//        SearchHistoryDataModel.s.expireCheck()
    }
}
