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
        DeleteTabUseCase().exe()
        InitializeTabUseCase().exe()
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

        CloseTabUseCase().exe()

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

        CloseTabAllUseCase().exe()

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

        CopyTabUseCase().exe()

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

        AddTabUseCase().exe()
        SwapTabUseCase().exe(start: 0, end: 1)

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

        AddTabUseCase().exe()
        RemoveTabUseCase().exe()

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

        AddTabUseCase().exe()
        RemoveTabUseCase().exe(context: GetHistoryTabUseCase().exe(index: 1)!.context)

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

        AddTabUseCase().exe()
        ChangeTabUseCase().exe(context: GetHistoryTabUseCase().exe(index: 0)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testChangeGroupTitle() {
        AddTabUseCase().exe()
        ChangeGroupTitleUseCase().exe(groupContext: tabUseCase.tabGroupList.currentGroupContext, title: #function)
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

        AddTabUseCase().exe()

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

        AddGroupUseCase().exe()

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

        InsertTabUseCase().exe()

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

        InsertTabUseCase().exe(url: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testDelete() {
        AddTabUseCase().exe()
        DeleteTabUseCase().exe()
        XCTAssertTrue(tabUseCase.tabs.count == 1)
    }

    func testGetIndex() {
        AddTabUseCase().exe()
        XCTAssertTrue(GetIndexTabUseCase().exe(context: GetHistoryTabUseCase().exe(index: 1)!.context) == 1)
    }

    func testGetHistory() {
        AddTabUseCase().exe(url: #function)
        XCTAssertTrue(GetHistoryTabUseCase().exe(index: 1)!.url == #function)
    }

    func testStartLoading() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .startLoading = action {
                    if let expectation = expectation {
                        XCTAssertTrue(GetHistoryTabUseCase().exe(index: 0)!.isLoading == true)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        StartLoadingTabUseCase().exe(context: GetHistoryTabUseCase().exe(index: 0)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndLoading() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .endLoading = action {
                    if let expectation = expectation {
                        XCTAssertTrue(GetHistoryTabUseCase().exe(index: 0)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        EndLoadingTabUseCase().exe(context: GetHistoryTabUseCase().exe(index: 0)!.context)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testEndRendering() {
        weak var expectation = self.expectation(description: #function)

        tabUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .endRendering = action {
                    if let expectation = expectation {
                        XCTAssertTrue(GetHistoryTabUseCase().exe(index: 0)!.isLoading == false)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        EndRenderingTabUseCase().exe(context: GetHistoryTabUseCase().exe(index: 0)!.context)

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

        AddTabUseCase().exe()
        GoBackTabUseCase().exe()

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

        AddTabUseCase().exe()
        GoBackTabUseCase().exe()
        GoNextTabUseCase().exe()

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
