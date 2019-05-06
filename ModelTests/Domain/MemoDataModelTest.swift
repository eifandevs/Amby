//
//  MemoDataModelTest.swift
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

class MemoDataModelTest: XCTestCase {
    var memoDataModel: MemoDataModelProtocol {
        return MemoDataModel.s
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        memoDataModel.delete()
    }

    func testInsert() {
        weak var expectation = self.expectation(description: #function)

        memoDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .insert = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        let memo = Memo()
        memo.text = #function
        memoDataModel.insert(memo: memo)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSelect() {
        let memo = Memo()
        memo.text = #function
        memoDataModel.insert(memo: memo)
        XCTAssertTrue(memoDataModel.select().first!.text == #function)
    }

    func testSelectWithId() {
        let memo = Memo()
        memo.text = #function
        memoDataModel.insert(memo: memo)
        XCTAssertTrue(memoDataModel.select(id: memo.id)!.text == #function)
    }

    func testUpdate() {
        weak var expectation = self.expectation(description: #function)

        let memo = Memo()
        memo.text = "tmp"
        memoDataModel.insert(memo: memo)

        memoDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .update = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.memoDataModel.select().first!.text == #function)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        memoDataModel.update(memo: memo, text: #function)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testInvertLock() {
        weak var expectation = self.expectation(description: #function)

        let memo = Memo()
        memo.text = "tmp"
        memo.isLocked = false
        memoDataModel.insert(memo: memo)

        memoDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .invertLock = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.memoDataModel.select().first!.isLocked == true)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        memoDataModel.invertLock(memo: memo)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testDelete() {
        weak var expectation = self.expectation(description: #function)

        let memo = Memo()
        memo.text = "tmp"
        memo.isLocked = false
        memoDataModel.insert(memo: memo)

        memoDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .deleteAll = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.memoDataModel.select().count == 0)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        memoDataModel.delete()

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testDeleteWithObject() {
        weak var expectation = self.expectation(description: #function)

        let memo = Memo()
        memo.text = "tmp"
        memo.isLocked = false
        memoDataModel.insert(memo: memo)

        memoDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .delete = action {
                    if let expectation = expectation {
                        XCTAssertTrue(self.memoDataModel.select().count == 0)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        memoDataModel.delete(memo: memo)

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
