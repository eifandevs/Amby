//
//  PageHistoryDataModelTests.swift
//  Qas-DevelopTests
//
//  Created by tenma on 2018/03/30.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qas_Develop

class PageHistoryDataModelTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        PageHistoryDataModel.s.delete()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        PageHistoryDataModel.s.delete()
    }
    
    func testInitialize() {
        PageHistoryDataModel.s.initialize()
        XCTAssertTrue(PageHistoryDataModel.s.histories.count == 1)
        
        PageHistoryDataModel.s.append(url: "testInitialize")
        PageHistoryDataModel.s.store()
        
        PageHistoryDataModel.s.initialize()
        XCTAssertTrue(PageHistoryDataModel.s.histories.count == 2)
    }
    
    func testStartLoading() {
        let expectation = self.expectation(description: "testStartLoading")
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidStartLoading
            .subscribe { element in
                XCTAssertTrue(element.element! == "testStartLoading")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        PageHistoryDataModel.s.startLoading(context: "testStartLoading")
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
