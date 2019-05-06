//
//  ProgressDataModelTest.swift
//  ModelTests
//
//  Created by iori tenma on 2019/04/22.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model
@testable import Entity

class ProgressDataModelTest: XCTestCase {

    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

    var progressDataModel: ProgressDataModelProtocol {
        return ProgressDataModel.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testUpdateProgress() {
        weak var expectation = self.expectation(description: #function)

        progressDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .updateProgress(progress) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(progress == 0.5)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        progressDataModel.updateProgress(progress: 0.5)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateText() {
        weak var expectation = self.expectation(description: #function)

        progressDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .updateText(text) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(text == #function)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        progressDataModel.updateText(text: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
