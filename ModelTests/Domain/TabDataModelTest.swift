//
//  TabDataModelTests.swift
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
@testable import Entity

class TabDataModelTests: XCTestCase {

    let disposeBag = DisposeBag()

    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

    var histories: [Tab] {
        return TabDataModel.s.histories
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        TabDataModel.s.delete()
        TabDataModel.s.initialize()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialize() {
        TabDataModel.s.initialize()
        XCTAssertTrue(histories.count == 1)
    }

    func testGetHistory() {
        TabDataModel.s.append(url: dummyUrl)
        XCTAssertTrue(TabDataModel.s.getHistory(context: TabDataModel.s.getHistory(index: 1)!.context)!.url == dummyUrl)
        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.url == dummyUrl)
    }

    func testGetIsLoading() {
        TabDataModel.s.append()
        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.isLoading == false)
    }

    func testStartLoading() {
        TabDataModel.s.append()

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .startLoading(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.context == context)
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.isLoading == true)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.startLoading(context: histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndLoading() {
        TabDataModel.s.append()
        TabDataModel.s.startLoading(context: TabDataModel.s.getHistory(index: 1)!.context)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .endLoading(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.context == context)
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.endLoading(context: TabDataModel.s.getHistory(index: 1)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndRendering() {
        TabDataModel.s.append()
        TabDataModel.s.startLoading(context: TabDataModel.s.getHistory(index: 1)!.context)
        TabDataModel.s.endLoading(context: TabDataModel.s.getHistory(index: 1)!.context)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .endRendering(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.context == context)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.endRendering(context: TabDataModel.s.getHistory(index: 1)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSwap() {
        TabDataModel.s.append()
        TabDataModel.s.append()
        TabDataModel.s.startLoading(context: TabDataModel.s.getHistory(index: 1)!.context)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .swap(start, end) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(start == 1)
                        XCTAssertTrue(end == 0)
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 0)!.isLoading == true)
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.swap(start: 1, end: 0)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateUrl() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.updateUrl(context: TabDataModel.s.getHistory(index: 1)!.context, url: dummyUrl2)
        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.url == dummyUrl2)
    }

    func testUpdateTitle() {
        TabDataModel.s.append(url: dummyUrl, title: dummyTitle)
        TabDataModel.s.updateTitle(context: TabDataModel.s.getHistory(index: 1)!.context, title: dummyTitle2)
        XCTAssertTrue(TabDataModel.s.getHistory(index: 1)!.title == dummyTitle2)
    }

    func testInsert() {
        TabDataModel.s.append(url: dummyUrl, title: dummyTitle)
        TabDataModel.s.append(url: dummyUrl, title: dummyTitle)
        TabDataModel.s.insert(url: dummyUrl, title: nil)
        TabDataModel.s.change(context: TabDataModel.s.getHistory(index: 1)!.context)

        XCTAssertTrue(TabDataModel.s.getHistory(index: 3)!.title == "")

        weak var expectation = self.expectation(description: #function)
        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .insert(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(before.tab.url == self.dummyUrl)
                        XCTAssertTrue(before.tab.title == self.dummyTitle)
                        XCTAssertTrue(after.tab.url == "")
                        XCTAssertTrue(after.tab.title == self.dummyTitle)
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 2)!.url == "")
                        XCTAssertTrue(TabDataModel.s.getHistory(index: 2)!.title == self.dummyTitle)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.insert(url: nil, title: dummyTitle)
        self.waitForExpectations(timeout: 10, handler: nil)

    }

    func testAppend() {
        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .append(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(after.tab.url == self.dummyUrl)
                        XCTAssertTrue(before!.tab.url == "")
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.append(url: dummyUrl)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testAppendGroup() {
        TabDataModel.s.append(url: dummyUrl)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .appendGroup = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.appendGroup()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChangeGroupTitle() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.appendGroup()

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .changeGroupTitle(groupContext, title) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(title == self.dummyTitle)
                        XCTAssertTrue(groupContext == TabDataModel.s.tabGroupList.groups[1].groupContext)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.changeGroupTitle(groupContext: TabDataModel.s.tabGroupList.groups[1].groupContext, title: dummyTitle)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRemoveGroup() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.appendGroup()

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .deleteGroup = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.removeGroup(groupContext: TabDataModel.s.tabGroupList.groups[1].groupContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInvertPrivateMode() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.appendGroup()

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .invertPrivateMode = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.invertPrivateMode(groupContext: TabDataModel.s.tabGroupList.groups[1].groupContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopy() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.append(url: dummyUrl2)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .append = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopyWithInsert() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.append(url: dummyUrl2)
        TabDataModel.s.change(context: histories[1].context)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .insert = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRebuild() {
        // NSInternalInconsistencyExceptionが発生する(rebuild)
        //        TabDataModel.s.append(url: dummyUrl)

        //        weak var expectation = self.expectation(description: #function)
        //
        //        TabDataModel.s.rx_action
        //            .subscribe { object in
        //                if let action = object.element, case .rebuildThumbnail = action {
        //                    if let expectation = expectation {
        //                        expectation.fulfill()
        //                    }
        //                }
        //            }
        //            .disposed(by: disposeBag)
        //
        //        TabDataModel.s.rebuild()
        //
        //        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetIndex() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.append(url: dummyUrl2)
        _ = TabDataModel.s.getIndex(context: histories[1].context)
    }

    func testRemove() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.append(url: dummyUrl2)
        TabDataModel.s.remove(context: histories[1].context)
        TabDataModel.s.remove(context: histories[1].context)
        TabDataModel.s.remove(context: histories[0].context)
    }

    func testChange() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.append(url: dummyUrl2)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case let .change(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(after.tab.url == self.dummyUrl)
                        XCTAssertTrue(before.tab.url == self.dummyUrl2)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.change(context: histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChangeGroup() {
        // NSInternalInconsistencyExceptionが発生する(rebuild)
        //        TabDataModel.s.append(url: dummyUrl, title: dummyTitle)
        //        TabDataModel.s.appendGroup()
        //        TabDataModel.s.changeGroup(groupContext: TabDataModel.s.tabGroupList.groups[1].groupContext)
    }

    func testGoBack() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.append(url: dummyUrl2)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .change = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.goBack()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoNext() {
        TabDataModel.s.append(url: dummyUrl)
        TabDataModel.s.append(url: dummyUrl2)
        TabDataModel.s.change(context: histories[1].context)

        weak var expectation = self.expectation(description: #function)

        TabDataModel.s.rx_action
            .subscribe { object in
                if let action = object.element, case .change = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        TabDataModel.s.goNext()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testStore() {
        TabDataModel.s.append(url: dummyUrl, title: dummyTitle)
        TabDataModel.s.append(url: dummyUrl2, title: dummyTitle2)
        TabDataModel.s.store()
    }

    func testDelete() {
        TabDataModel.s.append(url: dummyUrl, title: dummyTitle)
        TabDataModel.s.append(url: dummyUrl2, title: dummyTitle2)
        TabDataModel.s.store()
        TabDataModel.s.delete()
    }
}
