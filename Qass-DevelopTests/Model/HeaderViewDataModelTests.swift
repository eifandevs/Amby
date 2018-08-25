//
//  ProgressDataModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/06/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class ProgressDataModelTests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUpdateProgress() {
        weak var expectation = self.expectation(description: #function)

        ProgressDataModel.s.rx_progressDataModelDidUpdateProgress
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element! == 0.75)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        ProgressDataModel.s.updateProgress(progress: 0.75)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateText() {
        weak var expectation = self.expectation(description: #function)

        ProgressDataModel.s.rx_progressDataModelDidUpdateText
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element! == #function)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        ProgressDataModel.s.updateText(text: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testBeginEditing() {
        weak var expectation = self.expectation(description: #function)

        ProgressDataModel.s.rx_progressDataModelDidBeginEditing
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element!)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        ProgressDataModel.s.beginEditing(forceEditFlg: true)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
