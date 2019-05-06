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
        return tabDataModel.histories
    }

    var tabDataModel: TabDataModelProtocol {
        return TabDataModel.s
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        tabDataModel.delete()
        tabDataModel.initialize()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialize() {
        tabDataModel.initialize()
        XCTAssertTrue(histories.count == 1)
    }

    func testGetHistory() {
        tabDataModel.append(url: dummyUrl, title: nil)
        XCTAssertTrue(tabDataModel.getHistory(context: tabDataModel.getHistory(index: 1)!.context)!.url == dummyUrl)
        XCTAssertTrue(tabDataModel.getHistory(index: 1)!.url == dummyUrl)
    }

    func testGetIsLoading() {
        tabDataModel.append(url: nil, title: nil)
        XCTAssertTrue(tabDataModel.getHistory(index: 1)!.isLoading == false)
    }

    func testStartLoading() {
        tabDataModel.append(url: nil, title: nil)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .startLoading(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 1)!.context == context)
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 1)!.isLoading == true)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.startLoading(context: histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndLoading() {
        tabDataModel.append(url: nil, title: nil)
        tabDataModel.startLoading(context: tabDataModel.getHistory(index: 1)!.context)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .endLoading(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 1)!.context == context)
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 1)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.endLoading(context: tabDataModel.getHistory(index: 1)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndRendering() {
        tabDataModel.append(url: nil, title: nil)
        tabDataModel.startLoading(context: tabDataModel.getHistory(index: 1)!.context)
        tabDataModel.endLoading(context: tabDataModel.getHistory(index: 1)!.context)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .endRendering(context) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 1)!.context == context)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.endRendering(context: tabDataModel.getHistory(index: 1)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSwap() {
        tabDataModel.append(url: nil, title: nil)
        tabDataModel.append(url: nil, title: nil)
        tabDataModel.startLoading(context: tabDataModel.getHistory(index: 1)!.context)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .swap(start, end) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(start == 1)
                        XCTAssertTrue(end == 0)
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 0)!.isLoading == true)
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 1)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.swap(start: 1, end: 0)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateUrl() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.updateUrl(context: tabDataModel.getHistory(index: 1)!.context, url: dummyUrl2)
        XCTAssertTrue(tabDataModel.getHistory(index: 1)!.url == dummyUrl2)
    }

    func testUpdateTitle() {
        tabDataModel.append(url: dummyUrl, title: dummyTitle)
        tabDataModel.updateTitle(context: tabDataModel.getHistory(index: 1)!.context, title: dummyTitle2)
        XCTAssertTrue(tabDataModel.getHistory(index: 1)!.title == dummyTitle2)
    }

    func testInsert() {
        tabDataModel.append(url: dummyUrl, title: dummyTitle)
        tabDataModel.append(url: dummyUrl, title: dummyTitle)
        tabDataModel.insert(url: dummyUrl, title: nil)
        tabDataModel.change(context: tabDataModel.getHistory(index: 1)!.context)

        XCTAssertTrue(tabDataModel.getHistory(index: 3)!.title == "")

        weak var expectation = self.expectation(description: #function)
        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .insert(before, after) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(before.tab.url == self.dummyUrl)
                        XCTAssertTrue(before.tab.title == self.dummyTitle)
                        XCTAssertTrue(after.tab.url == "")
                        XCTAssertTrue(after.tab.title == self.dummyTitle)
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 2)!.url == "")
                        XCTAssertTrue(self.tabDataModel.getHistory(index: 2)!.title == self.dummyTitle)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.insert(url: nil, title: dummyTitle)
        self.waitForExpectations(timeout: 10, handler: nil)

    }

    func testAppend() {
        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
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

        tabDataModel.append(url: dummyUrl, title: nil)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testAppendGroup() {
        tabDataModel.append(url: dummyUrl, title: nil)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .appendGroup = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.appendGroup()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChangeGroupTitle() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.appendGroup()

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .changeGroupTitle(groupContext, title) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(title == self.dummyTitle)
                        XCTAssertTrue(groupContext == self.tabDataModel.tabGroupList.groups[1].groupContext)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.changeGroupTitle(groupContext: tabDataModel.tabGroupList.groups[1].groupContext, title: dummyTitle)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRemoveGroup() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.appendGroup()

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .deleteGroup = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.removeGroup(groupContext: tabDataModel.tabGroupList.groups[1].groupContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInvertPrivateMode() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.appendGroup()

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .invertPrivateMode = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.invertPrivateMode(groupContext: tabDataModel.tabGroupList.groups[1].groupContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopy() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.append(url: dummyUrl2, title: nil)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .append = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopyWithInsert() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.append(url: dummyUrl2, title: nil)
        tabDataModel.change(context: histories[1].context)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .insert = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRebuild() {
        // NSInternalInconsistencyExceptionが発生する(rebuild)
        //        tabDataModel.append(url: dummyUrl)

        //        weak var expectation = self.expectation(description: #function)
        //
        //        tabDataModel.rx_action
        //            .subscribe { object in
        //                if let action = object.element, case .rebuildThumbnail = action {
        //                    if let expectation = expectation {
        //                        expectation.fulfill()
        //                    }
        //                }
        //            }
        //            .disposed(by: disposeBag)
        //
        //        tabDataModel.rebuild()
        //
        //        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetIndex() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.append(url: dummyUrl2, title: nil)
        _ = tabDataModel.getIndex(context: histories[1].context)
    }

    func testRemove() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.append(url: dummyUrl2, title: nil)
        tabDataModel.remove(context: histories[1].context)
        tabDataModel.remove(context: histories[1].context)
        tabDataModel.remove(context: histories[0].context)
    }

    func testChange() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.append(url: dummyUrl2, title: nil)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
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

        tabDataModel.change(context: histories[1].context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChangeGroup() {
        // NSInternalInconsistencyExceptionが発生する(rebuild)
        //        tabDataModel.append(url: dummyUrl, title: dummyTitle)
        //        tabDataModel.appendGroup()
        //        tabDataModel.changeGroup(groupContext: tabDataModel.tabGroupList.groups[1].groupContext)
    }

    func testGoBack() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.append(url: dummyUrl2, title: nil)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .change = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.goBack()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoNext() {
        tabDataModel.append(url: dummyUrl, title: nil)
        tabDataModel.append(url: dummyUrl2, title: nil)
        tabDataModel.change(context: histories[1].context)

        weak var expectation = self.expectation(description: #function)

        tabDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .change = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabDataModel.goNext()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testStore() {
        tabDataModel.append(url: dummyUrl, title: dummyTitle)
        tabDataModel.append(url: dummyUrl2, title: dummyTitle2)
        tabDataModel.store()
    }

    func testDelete() {
        tabDataModel.append(url: dummyUrl, title: dummyTitle)
        tabDataModel.append(url: dummyUrl2, title: dummyTitle2)
        tabDataModel.store()
        tabDataModel.delete()
    }
}
