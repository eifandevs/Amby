//
//  FavoriteDataModelTest.swift
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

class FavoriteDataModelTest: XCTestCase {

    let dummyUrl = "https://abc/"
    let dummyUrl2 = "https://def/"
    let dummyTitle = "dummyTitle"
    let dummyTitle2 = "dummyTitle2"

    var favoriteDataModel: FavoriteDataModelProtocol {
        return FavoriteDataModel.s
    }

    var dummyFavorite: Favorite {
        let fd = Favorite()
        fd.title = dummyTitle
        fd.url = dummyUrl
        return fd
    }

    var dummyFavorite2: Favorite {
        let fd = Favorite()
        fd.title = dummyTitle2
        fd.url = dummyUrl2
        return fd
    }

    var dummyTab: Tab {
        return Tab(url: dummyUrl, title: dummyTitle)
    }

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        favoriteDataModel.delete()
    }

    func testInsert() {
        weak var expectation = self.expectation(description: #function)

        favoriteDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case .insert = action {
                    if let expectation = expectation {
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        favoriteDataModel.insert(favorites: [dummyFavorite])

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testSelect() {
        let dummyFavorite = self.dummyFavorite
        favoriteDataModel.insert(favorites: [dummyFavorite])
        let result = favoriteDataModel.select()
        XCTAssertTrue(result.count == 1)
        XCTAssertTrue(result.first!.id == dummyFavorite.id)

        let resultWithId = favoriteDataModel.select(id: dummyFavorite.id)
        XCTAssertTrue(resultWithId.count == 1)
        XCTAssertTrue(resultWithId.first!.title == dummyFavorite.title)
        XCTAssertTrue(resultWithId.first!.url == dummyFavorite.url)

        let resultWithUrl = favoriteDataModel.select(url: dummyFavorite.url)
        XCTAssertTrue(resultWithUrl.count == 1)
        XCTAssertTrue(resultWithUrl.first!.title == dummyFavorite.title)
        XCTAssertTrue(resultWithUrl.first!.url == dummyFavorite.url)
    }

    func testDelete() {
        favoriteDataModel.insert(favorites: [dummyFavorite])
        favoriteDataModel.delete()
        XCTAssertTrue(favoriteDataModel.select().count == 0)
    }

    func testDeleteWithFavorites() {
        let dummyFavorite = self.dummyFavorite
        let dummyFavorite2 = self.dummyFavorite2

        favoriteDataModel.insert(favorites: [dummyFavorite, dummyFavorite2])
        favoriteDataModel.delete(favorites: [dummyFavorite])

        let result = favoriteDataModel.select()
        XCTAssertTrue(result.count == 1)
        XCTAssertTrue(result.first!.id == dummyFavorite2.id)
    }

    func testReload() {
        weak var expectation = self.expectation(description: #function)

        favoriteDataModel.rx_action
            .subscribe { object in
                if let action = object.element, case let .reload(url) = action {
                    if let expectation = expectation {
                        XCTAssertTrue(url == self.dummyUrl)
                        expectation.fulfill()
                    }
                }
            }
            .disposed(by: disposeBag)

        favoriteDataModel.reload(currentTab: dummyTab)

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdate() {
        let dummyTab = self.dummyTab
        favoriteDataModel.update(currentTab: dummyTab)
        let beforeResult = favoriteDataModel.select()
        XCTAssertTrue(beforeResult.count == 1)
        XCTAssertTrue(beforeResult.first!.url == dummyTab.url)

        favoriteDataModel.update(currentTab: dummyTab)
        let afterResult = favoriteDataModel.select()
        XCTAssertTrue(afterResult.count == 0)
    }
}
