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

    func testEndRenderingPageHistoryDataModel() {
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

    func testInsertPageHistoryDataModel() {
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

    func testInsertByEventPageHistoryDataModel() {

        viewModel.insertPageHistoryDataModel(url: "dummy")

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssert(element.element!.url == #function)
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

    func testStoreFormDataModel() {
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
        XCTAssertTrue(FormDataModel.s.select(id: form.id).first!.title == #function)
    }

    func testIsHistorySwipe() {
        XCTAssertTrue(viewModel.isHistorySwipe(touchPoint: CGPoint(x: 10, y: 10)))
    }

    func testIsActiveBaseViewController() {
        XCTAssertTrue(viewModel.isActiveBaseViewController())
    }

    func testGetPreviousCapture() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)
        XCTAssertNotNil(viewModel.getPreviousCapture())
    }

    func testGetNextCapture() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)
        XCTAssertNotNil(viewModel.getNextCapture())
    }

    func testReloadHeaderText() {
        viewModel.insertPageHistoryDataModel(url: #function)

        weak var expectation = self.expectation(description: #function)

        HeaderViewDataModel.s.rx_headerViewDataModelDidUpdateText
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssert(element.element! == #function)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.reloadHeaderText()
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoBackPageHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element! == PageHistoryDataModel.s.getHistory(index: 0)!.context)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.goBackPageHistoryDataModel()
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoNextPageHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.goBackPageHistoryDataModel()

        weak var expectation = self.expectation(description: #function)

        PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
            .subscribe { element in
                if let expectation = expectation {
                    XCTAssertTrue(element.element! == PageHistoryDataModel.s.getHistory(index: 1)!.context)
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.goNextPageHistoryDataModel()
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoBackCommonHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)

        weak var expectation = self.expectation(description: #function)

        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoBack
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.goBackCommonHistoryDataModel()
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGoForwardCommonHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)

        weak var expectation = self.expectation(description: #function)

        CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoForward
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.goForwardCommonHistoryDataModel()
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testCreateThumbnailDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.createThumbnailDataModel(context: PageHistoryDataModel.s.getHistory(index: 0)!.context)
    }

    func testWriteThumbnailDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)
        let image = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).getImage()
        let data = UIImagePNGRepresentation(image)!
        viewModel.writeThumbnailDataModel(context: PageHistoryDataModel.s.getHistory(index: 0)!.context, data: data)
    }

    func testUpdateHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)

        weak var expectation = self.expectation(description: #function)

        FavoriteDataModel.s.rx_favoriteDataModelDidReload
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        let targetContext = PageHistoryDataModel.s.getHistory(index: 1)!.context
        viewModel.updateHistoryDataModel(context: targetContext, url: "testUpdateHistoryDataModel", title: "testUpdateHistoryDataModel", operation: PageHistory.Operation.normal)
        XCTAssertTrue(CommonHistoryDataModel.s.histories.last!.url == "testUpdateHistoryDataModel")
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(context: targetContext)!.url == "testUpdateHistoryDataModel")

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testStoreHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)

        let targetContext = PageHistoryDataModel.s.getHistory(index: 1)!.context
        viewModel.updateHistoryDataModel(context: targetContext, url: "testStoreHistoryDataModel", title: "testStoreHistoryDataModel", operation: PageHistory.Operation.normal)
        viewModel.storeHistoryDataModel()

        XCTAssertTrue(CommonHistoryDataModel.s.getList().count == 1)
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(context: targetContext)?.url == "testStoreHistoryDataModel")
    }

    func testStoreSearchHistoryDataModel() {
        viewModel.storeSearchHistoryDataModel(title: #function)
        XCTAssertTrue(SearchHistoryDataModel.s.select(title: #function, readNum: 10).first!.title == #function)
    }

    func testStorePageHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: #function)
        viewModel.insertPageHistoryDataModel(url: #function)

        let targetContext = PageHistoryDataModel.s.getHistory(index: 1)!.context
        viewModel.updateHistoryDataModel(context: targetContext, url: "testStorePageHistoryDataModel", title: "testStorePageHistoryDataModel", operation: PageHistory.Operation.forward)
        viewModel.storePageHistoryDataModel()
        XCTAssertTrue(PageHistoryDataModel.s.getHistory(context: targetContext)?.url == #function)
    }

    func testDeleteThumbnailDataModel() {
        viewModel.deleteThumbnailDataModel(webView: EGWebView(id: #function))
    }

    func testEncrypt() {
        let data = viewModel.encrypt(value: #function)
        XCTAssertNotNil(data)
    }

    func testDecrypt() {
        let data = viewModel.encrypt(value: #function)
        XCTAssertTrue(viewModel.decrypt(value: data) == #function)
    }
}
