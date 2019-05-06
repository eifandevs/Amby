//
//  FormDataModelTest.swift
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

class FormDataModelTest: XCTestCase {

    let dummyUrl = "https://dummy/"
    let dummyTitle = "dummy"
    let dummyHost = "dummy"

    var formDataModel: FormDataModelProtocol {
        return FormDataModel.s
    }

    var dummyForm: Form {
        let form = Form()
        form.title = dummyTitle
        form.host = dummyHost
        form.url = dummyUrl
        return form
    }

    private let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        formDataModel.delete()
    }

    func testInsert() {
        weak var expectation = self.expectation(description: #function)

        formDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .insert = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        formDataModel.insert(forms: [dummyForm])

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSelect() {
        let dummyForm = self.dummyForm
        formDataModel.insert(forms: [dummyForm])
        do {
            let forms = formDataModel.select()
            XCTAssertTrue(forms.first!.id == dummyForm.id)
            XCTAssertTrue(forms.count == 1)
            XCTAssertTrue(forms.first!.url == dummyUrl)
        }

        do {
            let forms = formDataModel.select(id: dummyForm.id)
            XCTAssertTrue(forms.first!.id == dummyForm.id)
            XCTAssertTrue(forms.count == 1)
            XCTAssertTrue(forms.first!.url == dummyUrl)
        }

        do {
            let forms = formDataModel.select(url: dummyForm.url)
            XCTAssertTrue(forms.first!.id == dummyForm.id)
            XCTAssertTrue(forms.count == 1)
            XCTAssertTrue(forms.first!.url == dummyUrl)
        }
    }

    func testDelete() {
        formDataModel.insert(forms: [self.dummyForm])
        formDataModel.delete()
        XCTAssertTrue(formDataModel.select().count == 0)

        let dummyForm = self.dummyForm
        formDataModel.insert(forms: [dummyForm])
        formDataModel.delete(forms: [dummyForm])
        XCTAssertTrue(formDataModel.select().count == 0)
    }

    func testStore() {
        formDataModel.store(form: self.dummyForm)
        XCTAssertTrue(formDataModel.select().count == 0)
    }
}
