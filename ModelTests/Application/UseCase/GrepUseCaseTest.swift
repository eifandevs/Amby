//
//  GrepUseCaseTest.swift
//  ModelTests
//
//  Created by iori tenma on 2019/04/30.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model
@testable import Entity

class GrepUseCaseTest: XCTestCase {

    var grepUseCase: GrepUseCase {
        return GrepUseCase.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testBegin() {
        weak var expectation = self.expectation(description: #function)

        grepUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .begin = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        grepUseCase.begin()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testFinish() {
        weak var expectation = self.expectation(description: #function)

        grepUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .finish = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        grepUseCase.finish(hitNum: 10)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGrep() {
        weak var expectation = self.expectation(description: #function)

        grepUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case let .request(word) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(word == #function)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        grepUseCase.grep(word: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testNext() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 2

        grepUseCase.rx_action
            .subscribe { object in
                if let action = object.element, let expectation = expectation {
                    switch action {
                    case .finish, .next:
                        expectation.fulfill()
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        grepUseCase.finish(hitNum: 10)
        grepUseCase.next()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testPrevious() {
        weak var expectation = self.expectation(description: #function)
        expectation?.expectedFulfillmentCount = 3

        grepUseCase.rx_action
            .subscribe { object in
                if let action = object.element, let expectation = expectation {
                    switch action {
                    case .finish, .next, .previous:
                        expectation.fulfill()
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)

        grepUseCase.finish(hitNum: 10)
        grepUseCase.next()
        grepUseCase.previous()

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
