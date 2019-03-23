//
//  URL+Extend.swift
//  CommonUtil
//
//  Created by tenma on 2019/03/23.
//  ref: https://qiita.com/ShingoFukuyama/items/cf63c7347fbdbc4d3ce0
//
import Foundation

public extension URL {

    public func ext_set(scheme: String? = nil,
                 user: String? = nil,
                 password: String? = nil,
                 host: String? = nil,
                 port: Int? = nil,
                 path: String? = nil,
                 query: String? = nil,
                 fragment: String? = nil)
        -> URL? {
            var result = ""
            if let scheme = scheme ?? self.scheme,
                !scheme.characters.isEmpty {
                result += scheme + "://"
            }
            if let user = user ?? self.user,
                !user.characters.isEmpty {
                result += user
                if let password = password ?? self.password {
                    result += ":" + password
                }
                result += "@"
            }
            if let host = host ?? self.host,
                !host.characters.isEmpty {
                result += host
                if let port = port ?? self.port,
                    0...65535 ~= port {
                    result += ":\(port)"
                }
                result += path ?? self.path
                if self.hasDirectoryPath,
                    !result.hasSuffix("/") { // trailing slash or not
                    result += "/"
                }
                if let query = query ?? self.query,
                    !query.characters.isEmpty {
                    result += "?" + query
                }
                if let fragment = fragment ?? self.fragment,
                    !fragment.characters.isEmpty {
                    result += "#" + fragment
                }
            }
            return URL(string: result)
    }

}
