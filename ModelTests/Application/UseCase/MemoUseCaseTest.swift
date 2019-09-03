//
//   MemoHandlerUseCaseTest.swift
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

class  MemoHandlerUseCaseTest: XCTestCase {

    var memoUseCase: MemoHandlerUseCase {
        return  MemoHandlerUseCase.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testOpen() {
        weak var expectation = self.expectation(description: #function)

        memoUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .present = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        let memo = Memo()
        memo.text = #function
        memoUseCase.open(memo: memo)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
