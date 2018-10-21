////
////  ThumbnailDataModelTests.swift
////  QassTests
////
////  Created by tenma on 2018/06/18.
////  Copyright © 2018年 eifandevs. All rights reserved.
////
//
//import XCTest
//
//@testable import Qass
//
//class ThumbnailDataModelTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        ThumbnailDataModel.s.delete()
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testGetThumbnail() {
//        ThumbnailDataModel.s.create(context: "testGetThumbnail")
//        let image = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).getImage()
//        let data = UIImagePNGRepresentation(image)!
//        ThumbnailDataModel.s.write(context: "testGetThumbnail", data: data)
//        _ = ThumbnailDataModel.s.getThumbnail(context: "testGetThumbnail")
//    }
//
//    func testGetCapture() {
//        ThumbnailDataModel.s.create(context: "testGetThumbnail")
//        let image = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).getImage()
//        let data = UIImagePNGRepresentation(image)!
//        ThumbnailDataModel.s.write(context: "testGetThumbnail", data: data)
//        _ = ThumbnailDataModel.s.getCapture(context: "testGetThumbnail")
//    }
//
//    func testDeleteWithContext() {
//        ThumbnailDataModel.s.create(context: "testGetThumbnail")
//        let image = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).getImage()
//        let data = UIImagePNGRepresentation(image)!
//        ThumbnailDataModel.s.write(context: "testGetThumbnail", data: data)
//        let capture = ThumbnailDataModel.s.getCapture(context: "testGetThumbnail")
//        XCTAssertNotNil(capture)
//        ThumbnailDataModel.s.delete(context: "testGetThumbnail")
//        XCTAssertNil(ThumbnailDataModel.s.getCapture(context: "testGetThumbnail"))
//    }
//
//    func testDelete() {
//        ThumbnailDataModel.s.create(context: "testGetThumbnail")
//        let image = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).getImage()
//        let data = UIImagePNGRepresentation(image)!
//        ThumbnailDataModel.s.write(context: "testGetThumbnail", data: data)
//        let capture = ThumbnailDataModel.s.getCapture(context: "testGetThumbnail")
//        XCTAssertNotNil(capture)
//        ThumbnailDataModel.s.delete()
//        XCTAssertNil(ThumbnailDataModel.s.getCapture(context: "testGetThumbnail"))
//    }
//
//    func testCreate() {
//        (1...300).forEach { index in
//            ThumbnailDataModel.s.create(context: String(index))
//        }
//    }
//
//    func testWrite() {
//        ThumbnailDataModel.s.create(context: "testGetThumbnail")
//        let image = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).getImage()
//        let data = UIImagePNGRepresentation(image)!
//        ThumbnailDataModel.s.write(context: "testGetThumbnail", data: data)
//        _ = ThumbnailDataModel.s.getCapture(context: "testGetThumbnail")
//    }
//}
