//
//  HistoryHandlerUseCaseTest.swift
//  ModelTests
//
//  Created by iori tenma on 2019/04/30.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model
@testable import Entity

class HistoryHandlerUseCaseTest: XCTestCase {
    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

    var historyUseCase: HistoryHandlerUseCase {
        return HistoryHandlerUseCase.s
    }

    let disposeBag = DisposeBag()

    var todayString: String {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: "ja_JP")
        formatter.locale = jaLocale
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DeleteHistoryUseCase().exe()
    }

    func testLoad() {
        weak var expectation = self.expectation(description: #function)

        historyUseCase.rx_action
            .subscribe { object in
                if let action = object.element, case .load = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        historyUseCase.load(url: dummyUrl)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetList() {
        InsertHistoryUseCase().exe(url: URL(string: dummyUrl), title: dummyTitle)
        XCTAssertTrue(GetListHistoryUseCase().exe().count == 0)
    }

    func testSelect() {
        InsertHistoryUseCase().exe(url: URL(string: dummyUrl), title: dummyTitle)
        XCTAssertTrue(SelectHistoryUseCase().exe(dateString: todayString).count == 1)
    }
}
