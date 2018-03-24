//
//  CommonHistoryDataModelTest.swift
//  Qas-DevelopTests
//
//  Created by tenma on 2018/03/24.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

class CommonHistoryDataModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGoBack() {
        CommonHistoryDataModel.s.goBack()
    }
}
