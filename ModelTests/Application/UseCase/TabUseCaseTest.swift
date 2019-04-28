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
}
