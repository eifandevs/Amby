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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInsert() {
        let fd = Favorite()
        fd.title = "testInsert"
        fd.url = "testInsert"
        
        FavoriteDataModel.s.insert(favorites: [fd])
//        XCTAssertTrue(PageHistoryDataModel.s.histories.count == 2)
    }
    
}
