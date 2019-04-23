//
//  SettingDataModelTest.swift
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

class SettingDataModelTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SettingDataModel.s.initialize()
    }

    func testDefaultValue() {
        XCTAssertTrue(SettingDataModel.s.rootPasscode == "")
        XCTAssertTrue(SettingDataModel.s.lastReportDate == Date.distantPast)
        XCTAssertTrue(SettingDataModel.s.autoScrollInterval == 0.06)

        let menuOrder: [UserOperation] = [
            .menu,
            .close,
            .historyBack,
            .copy,
            .search,
            .add,
            .scrollUp,
            .autoScroll,
            .historyForward,
            .form,
            .closeAll,
            .grep
        ]
        XCTAssertTrue(SettingDataModel.s.menuOrder == menuOrder)
        XCTAssertTrue(SettingDataModel.s.newWindowConfirm == false)
        XCTAssertTrue(SettingDataModel.s.tabSaveCount == 30)
        XCTAssertTrue(SettingDataModel.s.commonHistorySaveCount == 90)
        XCTAssertTrue(SettingDataModel.s.searchHistorySaveCount == 90)
    }

    func testSetValue() {
        SettingDataModel.s.rootPasscode = "dummy"
        SettingDataModel.s.lastReportDate = Date()
        SettingDataModel.s.autoScrollInterval = 0.2

        let menuOrder: [UserOperation] = [
            .menu,
            .close,
            .historyBack,
            .add,
            .copy,
            .search,
            .scrollUp,
            .autoScroll,
            .form,
            .closeAll,
            .historyForward,
            .grep
        ]
        SettingDataModel.s.menuOrder = menuOrder
        SettingDataModel.s.newWindowConfirm = true
        XCTAssertTrue(SettingDataModel.s.rootPasscode == "dummy")
        XCTAssertTrue(SettingDataModel.s.lastReportDate.toString() == Date().toString())
        XCTAssertTrue(SettingDataModel.s.autoScrollInterval == 0.2)
        XCTAssertTrue(SettingDataModel.s.menuOrder == menuOrder)
        XCTAssertTrue(SettingDataModel.s.newWindowConfirm == true)
    }

    func testInitialize() {
        SettingDataModel.s.rootPasscode = "dummy"
        SettingDataModel.s.lastReportDate = Date()
        SettingDataModel.s.autoScrollInterval = 0.2

        let menuOrder: [UserOperation] = [
            .menu,
            .close,
            .historyBack,
            .add,
            .copy,
            .search,
            .scrollUp,
            .autoScroll,
            .form,
            .closeAll,
            .historyForward,
            .grep
        ]
        SettingDataModel.s.menuOrder = menuOrder
        SettingDataModel.s.newWindowConfirm = true

        SettingDataModel.s.initialize()

        XCTAssertTrue(SettingDataModel.s.rootPasscode == "")
        XCTAssertTrue(SettingDataModel.s.lastReportDate == Date.distantPast)
        XCTAssertTrue(SettingDataModel.s.autoScrollInterval == 0.06)

        let defaultMenuOrder: [UserOperation] = [
            .menu,
            .close,
            .historyBack,
            .copy,
            .search,
            .add,
            .scrollUp,
            .autoScroll,
            .historyForward,
            .form,
            .closeAll,
            .grep
        ]
        XCTAssertTrue(SettingDataModel.s.menuOrder == defaultMenuOrder)
        XCTAssertTrue(SettingDataModel.s.newWindowConfirm == false)
    }

    func testInitializeMenuOrder() {
        let menuOrder: [UserOperation] = [
            .menu,
            .close,
            .historyBack,
            .add,
            .copy,
            .search,
            .scrollUp,
            .autoScroll,
            .form,
            .closeAll,
            .historyForward,
            .grep
        ]
        SettingDataModel.s.menuOrder = menuOrder

        SettingDataModel.s.initializeMenuOrder()

        let defaultMenuOrder: [UserOperation] = [
            .menu,
            .close,
            .historyBack,
            .copy,
            .search,
            .add,
            .scrollUp,
            .autoScroll,
            .historyForward,
            .form,
            .closeAll,
            .grep
        ]
        XCTAssertTrue(SettingDataModel.s.menuOrder == defaultMenuOrder)
        XCTAssertTrue(SettingDataModel.s.newWindowConfirm == false)
    }
}

private extension Date {
    private func toString(format: String = "yyyyMMdd") -> String {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: "ja_JP")
        formatter.locale = jaLocale
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
