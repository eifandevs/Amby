//
//  SearchUseCaseTest.swift
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

class SearchUseCaseTest: XCTestCase {

    var searchUseCase: SearchUseCase {
        return SearchUseCase.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testBeginAtCircleMenu() {
        weak var expectation = self.expectation(description: #function)

        searchUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .searchAtMenu = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        searchUseCase.beginAtCircleMenu()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testBeginAtHeader() {
        weak var expectation = self.expectation(description: #function)

        searchUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .searchAtHeader = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        searchUseCase.beginAtHeader()

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
