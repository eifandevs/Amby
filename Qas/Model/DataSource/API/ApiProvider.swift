//
//  ApiProvider.swift
//  Qas
//
//  Created by tenma on 2018/03/21.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation
import Moya
import Alamofire

final class ApiProvider<T: TargetType>: MoyaProvider<T> {
    
    public init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
                stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                callbackQueue: DispatchQueue? = nil,
                plugins: [PluginType] = [],
                trackInflights: Bool = false) {
        
        let sessionManager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            // リクエストタイムアウト5秒
            configuration.timeoutIntervalForRequest = 5
            // リソースタイムアウト10秒
            configuration.timeoutIntervalForResource = 10
            return SessionManager(configuration: configuration)
        }()
        
        super.init(endpointClosure: endpointClosure,
                   stubClosure: stubClosure,
                   callbackQueue: callbackQueue,
                   manager: sessionManager,
                   plugins: plugins,
                   trackInflights: trackInflights)
    }
    
}
