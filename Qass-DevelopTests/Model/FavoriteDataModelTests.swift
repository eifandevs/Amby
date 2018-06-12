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
    
    func testSelect() {
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
    
    func testDelete() {
        let fd = Favorite()
        fd.title = #function
        fd.url = #function
        
        let fd2 = Favorite()
        fd2.title = #function
        fd2.url = #function
        
        FavoriteDataModel.s.insert(favorites: [fd, fd2])
        FavoriteDataModel.s.delete()
        
        XCTAssertTrue(FavoriteDataModel.s.select().count == 0)
    }
    
    func testDeletePartial() {
        let fd = Favorite()
        fd.title = #function
        fd.url = #function
        
        let fd2 = Favorite()
        fd2.title = #function
        fd2.url = #function
        
        weak var expectation = self.expectation(description: #function)
        
        FavoriteDataModel.s.rx_favoriteDataModelDidRemove
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                    XCTAssertTrue(FavoriteDataModel.s.select().count == 1)
                    XCTAssertTrue(FavoriteDataModel.s.select().first!.id == fd2.id)
                }
            }
            .disposed(by: disposeBag)
        
        FavoriteDataModel.s.insert(favorites: [fd, fd2])
        FavoriteDataModel.s.delete(favorites: [fd], notify: true)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDeleteAll() {
        let fd = Favorite()
        fd.title = #function
        fd.url = #function
        
        let fd2 = Favorite()
        fd2.title = #function
        fd2.url = #function
        
        weak var expectation = self.expectation(description: #function)
        
        FavoriteDataModel.s.rx_favoriteDataModelDidRemove
            .subscribe { _ in
                if let expectation = expectation {
                    expectation.fulfill()
                    XCTAssertTrue(FavoriteDataModel.s.select().count == 0)
                }
            }
            .disposed(by: disposeBag)
        
        FavoriteDataModel.s.insert(favorites: [fd, fd2])
        FavoriteDataModel.s.delete(notify: true)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
