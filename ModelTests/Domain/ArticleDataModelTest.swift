//
//  ArticleDataModelTest.swift
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

class ArticleDataModelTest: XCTestCase {
    var articleDataModel: ArticleDataModelProtocol {
        return ArticleDataModel.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testGet() {
        weak var expectation = self.expectation(description: #function)

        articleDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .update(articles) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(articles.count > 0)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        articleDataModel.get()

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
