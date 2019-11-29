//
//  GetTabResponse.swift
//  Entity
//
//  Created by tenma.i on 2019/11/29.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// タブ取得APIレスポンス
public struct GetTabResponse: Codable {

    public struct TabGroupList: Codable {
        public struct TabGroup: Codable {
            public struct Tab: Codable {
                public struct Session: Codable {
                    public var urls: [String]
                    public var currentPage: Int
                }
                public var context: String
                public var url: String
                public var title: String
                public var session: Session
                public var isLoading: Bool
            }
            public var groupContext: String
            public var title: String
            public var isPrivate: Bool
            public var currentContext: String
            public var histories: [Tab]
            public var backForwardContextList: [String]
        }
        public var currentGroupContext: String
        public var groups: [TabGroup]
    }

    public init(code: String, data: GetTabResponse.TabGroupList) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: GetTabResponse.TabGroupList
}
