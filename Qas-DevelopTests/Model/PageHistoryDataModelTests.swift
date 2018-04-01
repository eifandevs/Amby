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
        weak var expectation = self.expectation(description: "testStartLoading")
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidStartLoading
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element! == "testStartLoading")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        PageHistoryDataModel.s.startLoading(context: "testStartLoading")
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEndLoading(context: String) {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "testEndLoading")
        PageHistoryDataModel.s.append(url: "testEndLoading")
        
        weak var expectation = self.expectation(description: "testEndLoading")
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidEndLoading
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element! == PageHistoryDataModel.s.histories[1].context)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        PageHistoryDataModel.s.endLoading(context: PageHistoryDataModel.s.histories[1].context)
    }
    
    func testEndRendering(context: String) {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "testEndRendering")
        
        weak var expectation = self.expectation(description: "testEndRendering")
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidEndRendering
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element! == PageHistoryDataModel.s.histories[1].context)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        PageHistoryDataModel.s.endRendering(context: PageHistoryDataModel.s.histories[1].context)
    }
    
    func testIsPastViewing() {
        PageHistoryDataModel.s.initialize()
        let isPastViewing = PageHistoryDataModel.s.isPastViewing(context: PageHistoryDataModel.s.histories[0].context)
        
        XCTAssertFalse(isPastViewing)
    }
    
    func testGetMostForwardUrl() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "testGetMostForwardUrl")
        PageHistoryDataModel.s.append(url: "testGetMostForwardUrl")
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: "testGetMostForwardUrl", title: "testGetMostForwardUrl", operation: .normal)
        PageHistoryDataModel.s.store()
        
        let url = PageHistoryDataModel.s.getMostForwardUrl(context: PageHistoryDataModel.s.histories[1].context)
        XCTAssertTrue(url == "testGetMostForwardUrl")
    }
    
    func testGetBackURL() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "testGetBackURL")
        PageHistoryDataModel.s.append(url: "testGetBackURL")
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: "testGetBackURL", title: "testGetBackURL", operation: .normal)
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: "testGetBackURL", title: "testGetBackURL", operation: .normal)

        PageHistoryDataModel.s.store()
        let backUrl = PageHistoryDataModel.s.getBackUrl(context: PageHistoryDataModel.s.histories[1].context)

        XCTAssertTrue(backUrl == "testGetBackURL")
    }
    
    func testGetForwardUrl() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "testGetForwardURL")
        PageHistoryDataModel.s.append(url: "testGetForwardURL")
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: "testGetForwardURL", title: "testGetForwardURL", operation: .normal)
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: "testGetForwardURL", title: "testGetForwardURL", operation: .normal)
        
        PageHistoryDataModel.s.store()
        let backUrl = PageHistoryDataModel.s.getBackUrl(context: PageHistoryDataModel.s.histories[1].context)
        let forwardUrl = PageHistoryDataModel.s.getForwardUrl(context: PageHistoryDataModel.s.histories[1].context)
        
        XCTAssertTrue(forwardUrl == "testGetForwardURL")
    }
    
    func testUpdate() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "testGetForwardURL")
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: "testGetForwardURL", title: "testGetForwardURL", operation: .normal)
        XCTAssertTrue(PageHistoryDataModel.s.histories[1].backForwardList[PageHistoryDataModel.s.histories[1].listIndex] == "testGetForwardURL")
    }
    
    func testInsert() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "testInsert")
        PageHistoryDataModel.s.append(url: "testInsert")
        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.histories[1].context)
        PageHistoryDataModel.s.store()
        
        weak var expectation = self.expectation(description: "testInsert")
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.pageHistory.url == "testInsert")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        PageHistoryDataModel.s.insert(url: "testInsert")
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInsertToAppend() {
        PageHistoryDataModel.s.initialize()

        weak var expectation = self.expectation(description: "testInsertToAppend")

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.url == "testInsertToAppend")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        PageHistoryDataModel.s.insert(url: "testInsertToAppend")

        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testAppend() {
        PageHistoryDataModel.s.initialize()
        
        weak var expectation = self.expectation(description: "testAppend")

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.url == "testAppend")
                    XCTAssertTrue(PageHistoryDataModel.s.histories.last!.url == "testAppend")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: "testAppend")
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
