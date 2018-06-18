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
    
    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        CommonHistoryDataModel.s.delete()
        PageHistoryDataModel.s.delete()
        FormDataModel.s.delete()
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
        _ = viewModel.getBackUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)
        let forwardUrl = viewModel.getForwardUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)
        
        XCTAssertTrue(forwardUrl == #function)
    }
    
    func testStartLoadingPageHistoryDataModel() {
        weak var expectation = self.expectation(description: #function)
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidStartLoading
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.startLoadingPageHistoryDataModel(context: #function)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEndLoadingPageHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        
        weak var expectation = self.expectation(description: #function)
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidEndLoading
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.endLoadingPageHistoryDataModel(context: PageHistoryDataModel.s.histories.first!.context)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEndRenderingPageHistoryDataModel(context: String) {
        viewModel.insertPageHistoryDataModel(url: #function)
        
        weak var expectation = self.expectation(description: #function)
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidEndRendering
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.endRenderingPageHistoryDataModel(context: PageHistoryDataModel.s.histories.first!.context)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdateProgressHeaderViewDataModel() {
        weak var expectation = self.expectation(description: #function)
        
        HeaderViewDataModel.s.rx_headerViewDataModelDidUpdateProgress
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssert(element.element! == 10.0)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.updateProgressHeaderViewDataModel(object: 10.0)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInsertPageHistoryDataModel(url: String? = nil) {
        weak var expectation = self.expectation(description: #function)
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssert(element.element!.url == #function)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.insertPageHistoryDataModel(url: #function)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInsertByEventPageHistoryDataModel(url: String? = nil) {
        weak var expectation = self.expectation(description: #function)
        
        PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssert(element.element!.pageHistory.url == #function)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.insertByEventPageHistoryDataModel(url: #function)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testBeginEditingHeaderViewDataModel() {
        weak var expectation = self.expectation(description: #function)
        
        HeaderViewDataModel.s.rx_headerViewDataModelDidBeginEditing
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssert(element.element! == false)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.beginEditingHeaderViewDataModel()
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testStoreFormDataModel(form: Form) {
        let input = Input()
        input.formIndex = 0
        input.formInputIndex = 0
        input.value = Data()
        
        let form = Form()
        form.title = #function
        form.host = #function
        form.url = #function
        form.inputs.append(input)
        
        viewModel.storeFormDataModel(form: form)
        XCTAssert(FormDataModel.s.select(id: form.id).first!.title == #function)
    }
}
