////
////  FormDataModelTests.swift
////  QassTests
////
////  Created by tenma on 2018/04/19.
////  Copyright © 2018年 eifandevs. All rights reserved.
////
//
//import XCTest
//import RxSwift
//import RxCocoa
//import Realm
//import RealmSwift
//
//@testable import Qass
//
//class FormDataModelTests: XCTestCase {
//
//    let disposeBag = DisposeBag()
//
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        FormDataModel.s.delete()
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testInsert() {
//        let form = Form()
//        form.title = #function
//        form.host = #function
//        form.url = #function
//        FormDataModel.s.insert(forms: [form])
//
//        XCTAssertTrue(FormDataModel.s.select(url: form.url).first!.title == #function)
//    }
//
//    func testSelect() {
//        let form = Form()
//        form.title = #function
//        form.host = #function
//        form.url = #function
//        FormDataModel.s.insert(forms: [form])
//
//        XCTAssertTrue(FormDataModel.s.select().count == 1)
//        XCTAssertTrue(FormDataModel.s.select(url: form.url).first!.title == #function)
//        XCTAssertTrue(FormDataModel.s.select(id: form.id).first!.title == #function)
//    }
//
//    func testStore() {
//        let input = Input()
//        input.formIndex = 0
//        input.formInputIndex = 0
//        input.value = Data()
//
//        let form = Form()
//        form.title = #function
//        form.host = #function
//        form.url = #function
//        form.inputs.append(input)
//
//        FormDataModel.s.store(form: form)
//
//        XCTAssertTrue(FormDataModel.s.select().count == 1)
//        XCTAssertTrue(FormDataModel.s.select(url: form.url).first!.title == #function)
//        XCTAssertTrue(FormDataModel.s.select(id: form.id).first!.title == #function)
//    }
//
//    func testStoreFailed() {
//        let form = Form()
//        form.title = #function
//        form.host = #function
//        form.url = #function
//
//        FormDataModel.s.store(form: form)
//
//        XCTAssertTrue(FormDataModel.s.select().count == 0)
//    }
//}
