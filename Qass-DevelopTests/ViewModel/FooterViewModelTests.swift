//
//  FooterViewModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class FooterViewModelTests: XCTestCase {

    let viewModel = FooterViewModel()
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

    func testProperties() {
        _ = viewModel.pageHistories
        _ = viewModel.currentContext
        _ = viewModel.currentHistory
        _ = viewModel.currentLocation
    }

    func testChangePageHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)

        weak var expectation = self.expectation(description: #function)

        let targetContext = PageHistoryDataModel.s.histories.first!.context

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element! == targetContext)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.changePageHistoryDataModel(context: targetContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testRemovePageHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)

        weak var expectation = self.expectation(description: #function)
        let targetContext = PageHistoryDataModel.s.histories.first!.context

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element?.deleteContext == targetContext)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.removePageHistoryDataModel(context: targetContext)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

}
