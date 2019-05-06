//
//  ScrollUseCaseTest.swift
//  ModelTests
//
//  Created by iori tenma on 2019/05/01.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model
@testable import Entity

class ScrollUseCaseTest: XCTestCase {

    var scrollUseCase: ScrollUseCase {
        return ScrollUseCase.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testScrollUp() {
        weak var expectation = self.expectation(description: #function)

        scrollUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .scrollUp = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        scrollUseCase.scrollUp()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testAutoScroll() {
        weak var expectation = self.expectation(description: #function)

        scrollUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .autoScroll = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        scrollUseCase.autoScroll()

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
