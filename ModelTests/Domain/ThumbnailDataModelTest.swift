//
//  ThumbnailDataModelTest.swift
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

class ThumbnailDataModelTest: XCTestCase {
    var thumbnailDataModel: ThumbnailDataModelProtocol {
        return ThumbnailDataModel.s
    }

    let disposeBag = DisposeBag()

    var dummyImage: UIImage {
        let size = UIScreen.main.bounds.size
        let color = UIColor.blue
        UIGraphicsBeginImageContext(size)

        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        thumbnailDataModel.delete()
    }

    func testGetThumbnail() {
        thumbnailDataModel.create(context: #function)
        thumbnailDataModel.write(context: #function, data: dummyImage.pngData()!)
        XCTAssertNotNil(thumbnailDataModel.getThumbnail(context: #function))
    }

    func testGetCapture() {
        thumbnailDataModel.create(context: #function)
        thumbnailDataModel.write(context: #function, data: dummyImage.pngData()!)
        XCTAssertNotNil(thumbnailDataModel.getCapture(context: #function))
    }

    func testDelete() {
        thumbnailDataModel.create(context: #function)
        thumbnailDataModel.write(context: #function, data: dummyImage.pngData()!)
        thumbnailDataModel.delete(context: #function)
        XCTAssertNil(thumbnailDataModel.getCapture(context: #function))
        XCTAssertNil(thumbnailDataModel.getThumbnail(context: #function))
    }

    func testWrite() {
        thumbnailDataModel.create(context: #function)
        thumbnailDataModel.write(context: #function, data: dummyImage.pngData()!)
    }

}
