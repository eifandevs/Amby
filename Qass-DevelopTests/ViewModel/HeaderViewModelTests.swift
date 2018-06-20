//
//  HeaderViewModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/20.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class HeaderViewModelTests: XCTestCase {

    let viewModel = HeaderViewModel()

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        PageHistoryDataModel.s.delete()
        CommonHistoryDataModel.s.delete()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGoBackCommonHistoryDataModel() {
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)

        weak var expectation = self.expectation(description: #function)

        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoBack
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.goBackCommonHistoryDataModel()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoForwardCommonHistoryDataModel() {
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)

        weak var expectation = self.expectation(description: #function)

        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoForward
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.goForwardCommonHistoryDataModel()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSearchOperationDataModel() {
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

        viewModel.searchOperationDataModel(text: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRegisterFavoriteDataModel() {
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)

        viewModel.registerFavoriteDataModel()
    }

    func testRemovePageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.removePageHistoryDataModel()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

}
