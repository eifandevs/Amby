//
//  Tab.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class Tab: NSObject, NSCoding {
    public var context: String
    public var url: String
    public var title: String
    public var session: Session
    public var isLoading: Bool

    public init(context: String = NSUUID().uuidString,
                url: String = "",
                title: String = "",
                session: Session = Session(),
                isLoading: Bool = false) {
        self.context = context
        self.url = url
        self.title = title
        self.session = session
        self.isLoading = isLoading
    }

    public required convenience init?(coder decoder: NSCoder) {
        let context = decoder.decodeObject(forKey: "context") as! String
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let session = decoder.decodeObject(forKey: "session") as! Session
        let isLoading = decoder.decodeBool(forKey: "isLoading")
        self.init(context: context, url: url, title: title, session: session, isLoading: isLoading)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(context, forKey: "context")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(session, forKey: "session")
        aCoder.encode(isLoading, forKey: "isLoading")
    }
}
