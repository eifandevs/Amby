//
//  HeaderFieldViewModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/20.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class HeaderFieldViewModelTests: XCTestCase {

    let viewModel = HeaderFieldViewModel()

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExecuteOperationDataModel() {
        weak var expectation = self.expectation(description: #function)

        OperationDataModel.s.rx_operationDataModelDidChange
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element!.operation == .search)
                    XCTAssertTrue(element.element!.object! as! String == #function)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.executeOperationDataModel(operation: .search, object: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
