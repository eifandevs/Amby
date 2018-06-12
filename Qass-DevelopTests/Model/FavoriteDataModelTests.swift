//
//  FavoriteDataModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/04/18.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class FavoriteDataModelTests: XCTestCase {
    
    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        FavoriteDataModel.s.delete()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInsert() {
        let fd = Favorite()
        fd.title = #function
        fd.url = #function

        weak var expectation = self.expectation(description: #function)

        FavoriteDataModel.s.rx_favoriteDataModelDidInsert
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                    XCTAssertTrue(FavoriteDataModel.s.select(id: fd.id).count > 0)
                }
            }
            .disposed(by: disposeBag)

        FavoriteDataModel.s.insert(favorites: [fd])

        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
}
