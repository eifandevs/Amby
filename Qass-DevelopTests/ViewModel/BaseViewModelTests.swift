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
        PageHistoryDataModel.s.append(url: "https://abc")
        XCTAssertTrue(viewModel.getIndex(context: PageHistoryDataModel.s.histories[1].context) == 1)
    }

    func testGetMostForwardUrlPageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.histories[1].context, url: "https://abc", operation: .normal)
        XCTAssertTrue(viewModel.getMostForwardUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context) == "https://abc")
    }

    func testGetIsPastViewingPageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        let isPastViewing = viewModel.getIsPastViewingPageHistoryDataModel(context: PageHistoryDataModel.s.histories[0].context)
        XCTAssertFalse(isPastViewing)
    }

    func testGetBackUrlPageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.histories[1].context, url: "https://abc", operation: .normal)

        PageHistoryDataModel.s.store()
        let backUrl = viewModel.getBackUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)

        XCTAssertTrue(backUrl == "https://abc")
    }

    func testGetForwardUrlPageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.updateUrl(context: PageHistoryDataModel.s.histories[1].context, url: "https://abc", operation: .normal)

        PageHistoryDataModel.s.store()
        _ = viewModel.getBackUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)
        let forwardUrl = viewModel.getForwardUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context)

        XCTAssertTrue(forwardUrl == "https://abc")
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
        viewModel.insertPageHistoryDataModel(url: "https://abc")

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
        viewModel.insertPageHistoryDataModel(url: "https://abc")

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
                    XCTAssert(element.element!.url == "https://abc")
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        viewModel.insertByEventPageHistoryDataModel(url: "https://abc")

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
        form.url = "https://abc"
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
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        XCTAssertNotNil(viewModel.getPreviousCapture())
    }

    func testGetNextCapture() {
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        XCTAssertNotNil(viewModel.getNextCapture())
    }

    func testReloadHeaderViewDataModel() {
        HeaderViewDataModel.s.reload()
    }

    func testUpdateTextHeaderViewDataModel() {
        HeaderViewDataModel.s.updateText(text: "https://abc")
    }

    func testGoBackPageHistoryDataModel() {
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")

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
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")
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
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")

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
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")

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
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.createThumbnailDataModel(context: PageHistoryDataModel.s.getHistory(index: 0)!.context)
    }

    func testWriteThumbnailDataModel() {
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        viewModel.insertPageHistoryDataModel(url: "https://abc")
        let image = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).getImage()
        let data = UIImagePNGRepresentation(image)!
        viewModel.writeThumbnailDataModel(context: PageHistoryDataModel.s.getHistory(index: 0)!.context, data: data)
    }

    func testUpdateUrlPageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.append(url: "https://abc")
        viewModel.updateUrlPageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context, url: "https://abc", operation: .normal)
        XCTAssert(PageHistoryDataModel.s.getHistory(index: 1)?.url == "https://abc")
    }

    func testUpdateTitlePageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.append(url: "https://abc")
        viewModel.updateTitlePageHistoryDataModel(context: PageHistoryDataModel.s.histories[1].context, title: "updateUrlPageHistoryDataModel")
        XCTAssert(PageHistoryDataModel.s.getHistory(index: 1)?.title == "updateUrlPageHistoryDataModel")
    }

    func testInsertCommonHistoryDataModel() {
        viewModel.insertCommonHistoryDataModel(url: URL(string: "https://abc"), title: #function)
        XCTAssert(CommonHistoryDataModel.s.histories.last!.title == #function)
    }

    func testStoreHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.append(url: "https://abc")
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc"), title: #function)
        viewModel.storeHistoryDataModel()
    }

    func testStorePageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: "https://abc")
        PageHistoryDataModel.s.append(url: "https://abc")
        CommonHistoryDataModel.s.insert(url: URL(string: "https://abc"), title: #function)
        viewModel.storeHistoryDataModel()
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
