//
//  TabUseCaseTest.swift
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

class TabUseCaseTest: XCTestCase {
    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

    var tabUseCase: TabUseCase {
        return TabUseCase.s
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
}
