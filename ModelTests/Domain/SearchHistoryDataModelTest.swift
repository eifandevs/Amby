//
//  SearchHistoryDataModelTest.swift
//  ModelTests
//
//  Created by iori tenma on 2019/04/20.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import Model
@testable import Entity

class SearchHistoryDataModelTest: XCTestCase {

    let disposeBag = DisposeBag()

    let dummyText = "dummy"
    let dummyText2 = "dummy2"

    var searchHistoryDataModel: SearchHistoryDataModelProtocol {
        return SearchHistoryDataModel.s
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        searchHistoryDataModel.delete()
    }

    func testStore() {
        searchHistoryDataModel.store(text: dummyText)
    }

}
