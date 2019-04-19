//
//  URL+Extend.swift
//  CommonUtil
//
//  Created by tenma on 2019/03/23.
//
//
import Foundation

public extension URL {
    func queryItemAdded(name: String, value: String?) -> URL? {
        return self.queryItemsAdded([URLQueryItem(name: name, value: value)])
    }

    func queryItemsAdded(_ queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: nil != self.baseURL) else {
            return nil
        }
        components.queryItems = queryItems + (components.queryItems ?? [])
        return components.url
    }

    func queryParams() -> [String: String] {
        var params = [String: String]()

        guard let comps = URLComponents(string: self.absoluteString) else {
            return params
        }
        guard let queryItems = comps.queryItems else { return params }

        for queryItem in queryItems {
            params[queryItem.name] = queryItem.value
        }
        return params
    }

    var isRestoreSessionUrl: Bool {
        if absoluteString.isLocalUrl {
            return absoluteString.contains("RestoreSession")
        } else {
            return false
        }
    }

    var isValidUrl: Bool {
        return absoluteString.isValidUrl
    }

    var isLocalUrl: Bool {
        return absoluteString.isLocalUrl
    }
}
