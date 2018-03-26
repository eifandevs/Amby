//
//  CommonHistoryDataModelTests.swift
//  Qas-DevelopTests
//
//  Created by tenma on 2018/03/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qas_Develop

class CommonHistoryDataModelTests: XCTestCase {
    
    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGoBack() {
        let expectation = self.expectation(description: "goBack")

        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoBack
            .subscribe { _ in
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        CommonHistoryDataModel.s.goBack()

        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
