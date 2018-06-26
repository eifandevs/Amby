//
//  PageHistoryDataModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/03/30.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

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
    }

    func testInitialize() {
        PageHistoryDataModel.s.initialize()
        XCTAssertTrue(PageHistoryDataModel.s.histories.count == 1)

        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.store()

        XCTAssertTrue(PageHistoryDataModel.s.histories.count == 2)
    }

    func testStartLoading() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidStartLoading
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element! == #function)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.startLoading(context: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndLoading(context: String) {
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")

        weak var expectation = self.expectation(description: #function)

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
        PageHistoryDataModel.s.append(url: "https://abc/")

        weak var expectation = self.expectation(description: #function)

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
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.histories[1].context, url: #function, operation: .normal)
        PageHistoryDataModel.s.store()

        let url = PageHistoryDataModel.s.getMostForwardUrl(context: PageHistoryDataModel.s.histories[1].context)
        XCTAssertTrue(url == "https://abc/")
    }

    func testGetBackURL() {
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.histories[1].context, url: "https://abc/", operation: .normal)

        PageHistoryDataModel.s.store()
        let backUrl = PageHistoryDataModel.s.getBackUrl(context: PageHistoryDataModel.s.histories[1].context)

        XCTAssertTrue(backUrl == "https://abc/")
    }

    func testGetForwardUrl() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.histories[1].context, url: "https://abc/", operation: .normal)

        PageHistoryDataModel.s.store()
        PageHistoryDataModel.s.getBackUrl(context: PageHistoryDataModel.s.histories[1].context)
        let forwardUrl = PageHistoryDataModel.s.getForwardUrl(context: PageHistoryDataModel.s.histories[1].context)

        XCTAssertTrue(forwardUrl == "https://abc/")
    }

    func testUpdateTitle() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.updateTitle(context: PageHistoryDataModel.s.histories[1].context, title: "testUpdateTitle")

        XCTAssertTrue(PageHistoryDataModel.s.histories[1].title == "testUpdateTitle")
    }

    func testUpdateUrl() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.histories[1].context, url: "https://abc/", operation: .normal)

        XCTAssertTrue(PageHistoryDataModel.s.histories.last!.url == "https://abc/")
    }

    func testInsert() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.histories[1].context)
        PageHistoryDataModel.s.store()

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.pageHistory.url == "https://abc/")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        PageHistoryDataModel.s.insert(url: "https://abc/")

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInsertToAppend() {
        PageHistoryDataModel.s.initialize()

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.url == "https://abc/")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        PageHistoryDataModel.s.insert(url: "https://abc/")

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testAppend() {
        PageHistoryDataModel.s.initialize()

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.url == "https://abc/")
                    XCTAssertTrue(PageHistoryDataModel.s.histories.last!.url == "https://abc/")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: "https://abc/")

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopyWithInsert() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.histories[1].context)
        PageHistoryDataModel.s.store()

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.pageHistory.url == "https://abc/")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        PageHistoryDataModel.s.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopyWithAppend() {
        PageHistoryDataModel.s.append(url: "https://abc/")

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element!.url == "https://abc/")
                    XCTAssertTrue(PageHistoryDataModel.s.histories.last!.url == "https://abc/")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testReload() {
        PageHistoryDataModel.s.append(url: "https://abc/")

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidReload
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.reload()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetIndex() {
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")

        let index = PageHistoryDataModel.s.getIndex(context: PageHistoryDataModel.s.histories[1].context)
        XCTAssertTrue(index == 1)
    }

    func testRemoveAndEmpty() {
        PageHistoryDataModel.s.initialize()

        let deleteContext = PageHistoryDataModel.s.histories.first!.context

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
            .subscribe { object in
                XCTAssertTrue(object.element?.deleteContext == deleteContext)
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.histories.first!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRemove() {
        PageHistoryDataModel.s.append(url: "https://abc/")

        let deleteContext = PageHistoryDataModel.s.histories.first!.context

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element?.deleteContext == deleteContext)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.histories.first!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChange() {
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element! == PageHistoryDataModel.s.histories[1].context)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoBack() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element! == PageHistoryDataModel.s.histories[1].context)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.goBack()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoNext() {
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
            .subscribe { object in
                if let expectation = expectation {
                    XCTAssertTrue(object.element! == PageHistoryDataModel.s.histories.first!.context)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.goNext()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testStore() {
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.store()
    }

    func testDelete() {
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.append(url: "https://abc/")
        PageHistoryDataModel.s.delete()
        XCTAssertTrue(PageHistoryDataModel.s.histories.count == 0)
    }
}
