//
//  ProgressHandlerUseCaseTest.swift
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

class ProgressHandlerUseCaseTest: XCTestCase {

    var progressUseCase: ProgressHandlerUseCase {
        return ProgressHandlerUseCase.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testUpdateCanGoBack() {
        weak var expectation = self.expectation(description: #function)

        progressUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .updateCanGoBack = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        progressUseCase.updateCanGoBack(context: TabHandlerUseCase.s.currentContext, canGoBack: false)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateCanGoForward() {
        weak var expectation = self.expectation(description: #function)

        progressUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .updateCanGoForward = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        progressUseCase.updateCanGoForward(context: TabHandlerUseCase.s.currentContext, canGoForward: false)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
