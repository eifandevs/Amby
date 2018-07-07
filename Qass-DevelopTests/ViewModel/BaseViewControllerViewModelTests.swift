//
//  BaseViewControllerViewModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class BaseViewControllerViewModelTests: XCTestCase {

    let viewModel = BaseViewControllerViewModel()

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInsertByEventPageHistoryDataModel() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.append(url: "https://abc/")
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssert(element.element!.url == "https://abc/")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.insertByEventPageHistoryDataModel(url: "https://abc/")

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
