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

    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

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

    func testGetHistory() {
        PageHistoryDataModel.s.append(url: dummyUrl)
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)!.url == dummyUrl)
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.url == dummyUrl)
    }

    func testGetIsLoading() {
        PageHistoryDataModel.s.append()
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.isLoading == false)
    }

    func testStartLoading() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .startLoading(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.context == context)
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.isLoading == true)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append()
        PageHistoryDataModel.s.startLoading(context: PageHistoryDataModel.s.histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndLoading() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .endLoading(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.context == context)
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append()
        PageHistoryDataModel.s.startLoading(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)
        PageHistoryDataModel.s.endLoading(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndRendering() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .endRendering(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.context == context)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append()
        PageHistoryDataModel.s.startLoading(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)
        PageHistoryDataModel.s.endLoading(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)
        PageHistoryDataModel.s.endRendering(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSwap() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .swap(start, end) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(start == 1)
                        XCTAssertTrue(end == 0)
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 0)!.isLoading == true)
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append()
        PageHistoryDataModel.s.append()
        PageHistoryDataModel.s.startLoading(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)
        PageHistoryDataModel.s.swap(start: 1, end: 0)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateUrl() {
        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.getHistory(index: 1)!.context, url: dummyUrl2)
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.url == dummyUrl2)
    }

    func testUpdateTitle() {
        PageHistoryDataModel.s.append(url: dummyUrl, title: dummyTitle)
        PageHistoryDataModel.s.updateTitle(context: PageHistoryDataModel.s.getHistory(index: 1)!.context, title: dummyTitle2)
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 1)!.title == dummyTitle2)
    }

    func testInsert() {
        PageHistoryDataModel.s.append(url: dummyUrl, title: dummyTitle)
        PageHistoryDataModel.s.append(url: dummyUrl, title: dummyTitle)
        PageHistoryDataModel.s.insert(url: dummyUrl, title: nil)
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 3)!.title == "")

        weak var expectation = self.expectation(description: #function)
        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .insert(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(before.pageHistory.url == self.dummyUrl)
                        XCTAssertTrue(before.pageHistory.title == self.dummyTitle)
                        XCTAssertTrue(after.pageHistory.url == "")
                        XCTAssertTrue(after.pageHistory.title == self.dummyTitle)
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 2)!.url == "")
                        XCTAssertTrue(PageHistoryDataModel.s.getHistory(index: 2)!.title == self.dummyTitle)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.getHistory(index: 1)!.context)
        PageHistoryDataModel.s.insert(url: nil, title: dummyTitle)
        self.waitForExpectations(timeout: 10, handler: nil)

    }

    func testAppend() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .append(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(after.pageHistory.url == self.dummyUrl)
                        XCTAssertTrue(before!.pageHistory.url == "")
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: dummyUrl)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testAppendGroup() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .appendGroup = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.appendGroup()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChangeGroupTitle() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .changeGroupTitle(groupContext, title) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(title == self.dummyTitle)
                        XCTAssertTrue(groupContext == PageHistoryDataModel.s.pageGroupList.groups[1].groupContext)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.appendGroup()
        PageHistoryDataModel.s.changeGroupTitle(groupContext: PageHistoryDataModel.s.pageGroupList.groups[1].groupContext, title: dummyTitle)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRemoveGroup() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .deleteGroup = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.appendGroup()
        PageHistoryDataModel.s.removeGroup(groupContext: PageHistoryDataModel.s.pageGroupList.groups[1].groupContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInvertPrivateMode() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .invertPrivateMode = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.appendGroup()
        PageHistoryDataModel.s.invertPrivateMode(groupContext: PageHistoryDataModel.s.pageGroupList.groups[1].groupContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopy() {
        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.append(url: dummyUrl2)

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .append = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopyWithInsert() {
        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.append(url: dummyUrl2)
        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.histories[1].context)

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .insert = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChange() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .change(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(after.pageHistory.url == self.dummyUrl)
                        XCTAssertTrue(before.pageHistory.url == self.dummyUrl2)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        PageHistoryDataModel.s.append(url: dummyUrl)
        PageHistoryDataModel.s.append(url: dummyUrl2)
        PageHistoryDataModel.s.change(context: PageHistoryDataModel.s.histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testStore() {
        PageHistoryDataModel.s.append(url: dummyUrl, title: dummyTitle)
        PageHistoryDataModel.s.append(url: dummyUrl, title: dummyTitle)
        PageHistoryDataModel.s.store()
    }

    func testDelete() {
        PageHistoryDataModel.s.append(url: dummyUrl, title: dummyTitle)
        PageHistoryDataModel.s.append(url: dummyUrl, title: dummyTitle)
        PageHistoryDataModel.s.store()
        PageHistoryDataModel.s.delete()
    }
}
