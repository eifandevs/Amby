//
//  TabHandlerUseCaseTest.swift
//  ModelTests
//
//  Created by iori tenma on 2019/04/28.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model
@testable import Entity

class TabHandlerUseCaseTest: XCTestCase {
    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

    var tabUseCase: TabHandlerUseCase {
        return TabHandlerUseCase.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        tabUseCase.delete()
        tabUseCase.initialize()
    }

    func testPresentGroupTitleEdit() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case let .presentGroupTitleEdit(groupContext) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(groupContext == self.tabUseCase.currentContext)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.presentGroupTitleEdit(groupContext: tabUseCase.currentContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testClose() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .delete = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.close()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCloseAll() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .delete = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.closeAll()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testReload() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .reload = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.reload()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCopy() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .append = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.copy()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSwap() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 2

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element {
                    switch action {
                    case .append, .swap:
                        if let expectation = expectation {
                            expectation.fulfill()
                        }
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.add()
        tabUseCase.swap(start: 0, end: 1)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRemove() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 2

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element {
                    switch action {
                    case .append, .delete:
                        if let expectation = expectation {
                            expectation.fulfill()
                        }
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.add()
        tabUseCase.remove()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRemoveWithContext() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 2

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element {
                    switch action {
                    case .append, .delete:
                        if let expectation = expectation {
                            expectation.fulfill()
                        }
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.add()
        tabUseCase.remove(context: tabUseCase.getHistory(index: 1)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChange() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 2

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element {
                    switch action {
                    case .append, .change:
                        if let expectation = expectation {
                            expectation.fulfill()
                        }
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.add()
        tabUseCase.change(context: tabUseCase.getHistory(index: 0)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChangeGroupTitle() {
        tabUseCase.add()
        tabUseCase.changeGroupTitle(groupContext: tabUseCase.tabGroupList.currentGroupContext, title: #function)
        XCTAssertTrue(tabUseCase.tabGroupList.currentGroup.title == #function)
    }

    func testAdd() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .append = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.add()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testAppendGroup() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .appendGroup = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.addGroup()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInsert() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .append = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.insert()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInsertWithUrl() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .append = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.insert(url: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testDelete() {
        tabUseCase.add()
        tabUseCase.delete()
        XCTAssertTrue(tabUseCase.tabs.count == 1)
    }

    func testGetIndex() {
        tabUseCase.add()
        XCTAssertTrue(tabUseCase.getIndex(context: tabUseCase.getHistory(index: 1)!.context) == 1)
    }

    func testGetHistory() {
        tabUseCase.add(url: #function)
        XCTAssertTrue(tabUseCase.getHistory(index: 1)!.url == #function)
    }

    func testStartLoading() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .startLoading = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.tabUseCase.getHistory(index: 0)!.isLoading == true)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.startLoading(context: tabUseCase.getHistory(index: 0)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndLoading() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .endLoading = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.tabUseCase.getHistory(index: 0)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.endLoading(context: tabUseCase.getHistory(index: 0)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndRendering() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .endRendering = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.tabUseCase.getHistory(index: 0)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.endRendering(context: tabUseCase.getHistory(index: 0)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoBack() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 2

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element {
                    switch action {
                    case .append, .change:
                        if let expectation = expectation {
                            expectation.fulfill()
                        }
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.add()
        tabUseCase.goBack()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoNext() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 3

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element {
                    switch action {
                    case .append, .change:
                        if let expectation = expectation {
                            expectation.fulfill()
                        }
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.add()
        tabUseCase.goBack()
        tabUseCase.goNext()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testHistoryBack() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .historyBack = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.historyBack()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testHistoryForward() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .historyForward = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        tabUseCase.historyForward()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

}
