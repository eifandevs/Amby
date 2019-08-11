//
//  SuggestHandlerUseCaseTest.swift
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

class SuggestHandlerUseCaseTest: XCTestCase {

    var suggestUseCase: SuggestHandlerUseCase {
        return SuggestHandlerUseCase.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testSuggest() {
        weak var expectation = self.expectation(description: #function)

        suggestUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .request = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        suggestUseCase.suggest(word: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
