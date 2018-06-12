//
//  BaseViewModelTests.swift
//  Qass-DevelopTests
//
//  Created by tenma on 2018/04/03.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Qass_Develop

class BaseViewModelTests: XCTestCase {
    
    let viewModel = BaseViewModel()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        PageHistoryDataModel.s.delete()
    }
    
    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetIndex() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: #function)
        XCTAssertTrue(viewModel.getIndex(context: PageHistoryDataModel.s.histories[1].context) == 1)
    }
    
    func testGetMostForwardUrlPageHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: #function, title: #function, operation: .normal)
        XCTAssertTrue(viewModel.getMostForwardUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context) == #function)
    }
    
    func testGetIsPastViewingPageHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
        let isPastViewing = viewModel.getIsPastViewingPageHistoryDataModel(context: PageHistoryDataModel.s.histories[0].context)
        XCTAssertFalse(isPastViewing)
    }
    
    func testGetBackUrlPageHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: #function, title: #function, operation: .normal)
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: #function, title: #function, operation: .normal)
        
        PageHistoryDataModel.s.store()
        let backUrl = viewModel.getBackUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)
        
        XCTAssertTrue(backUrl == #function)
    }
    
    func testGetForwardUrlPageHistoryDataModel() {
        PageHistoryDataModel.s.initialize()
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.append(url: #function)
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: #function, title: #function, operation: .normal)
        PageHistoryDataModel.s.update(context: PageHistoryDataModel.s.histories[1].context, url: #function, title: #function, operation: .normal)
        
        PageHistoryDataModel.s.store()
        let backUrl = viewModel.getBackUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)
        let forwardUrl = viewModel.getForwardUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)
        
        XCTAssertTrue(forwardUrl == #function)
    }
}
