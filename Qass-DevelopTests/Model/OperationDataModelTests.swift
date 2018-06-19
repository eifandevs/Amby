//
//  OperationDataModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class OperationDataModelTests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExecuteOperation() {
        weak var expectation = self.expectation(description: #function)

        OperationDataModel.s.rx_operationDataModelDidChange
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element!.operation == .autoFill)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        OperationDataModel.s.executeOperation(operation: .autoFill, object: nil)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

}
