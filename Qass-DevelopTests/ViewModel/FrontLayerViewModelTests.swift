//
//  FrontLayerViewModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/20.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class FrontLayerViewModelTests: XCTestCase {

    let viewModel = FrontLayerViewModel()

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

    func testInsertPageHistoryDataModel() {
        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element!.url == "")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.insertPageHistoryDataModel()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testExecuteOperationDataModel() {
        weak var expectation = self.expectation(description: #function)

        OperationDataModel.s.rx_operationDataModelDidChange
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element!.operation == .autoFill)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.executeOperationDataModel(operation: .autoFill)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRegisterFavoriteDataModel() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)

        viewModel.registerFavoriteDataModel()
    }

    func testRemovePageHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
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

    func testBeginEditingProgressDataModel() {
        weak var expectation = self.expectation(description: #function)

        ProgressDataModel.s.rx_progressDataModelDidBeginEditing
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.beginEditingProgressDataModel()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoForwardCommonHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
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

    func testGoBackCommonHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
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
}
