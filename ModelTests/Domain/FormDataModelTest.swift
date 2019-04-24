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

    var formDataModel: FormDataModelProtocol {
        return FormDataModel.s
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //        fo_
    }
}
