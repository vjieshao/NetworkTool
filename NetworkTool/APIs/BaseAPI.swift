//
//  BaseAPI.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Moya

public protocol SugarTargetType: TargetType {
    var parameters: [String: Any]? { get }
}

extension SugarTargetType {
    public var parameters: [String: Any]? {
        return nil
    }
}

protocol BaseAPI: SugarTargetType {
    func parameterEncoding() -> Moya.ParameterEncoding
}

extension BaseAPI {
    
    public var baseURL: URL {
        return URL(string: ServerConfigManager.shared().getApiHost())!
    }

    func parameterEncoding() -> Moya.ParameterEncoding {
        return URLEncoding()
    }

    public var headers: [String: String]? {
        return ServerConfigManager.shared().getHeader()
    }

    public var task: Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding())
    }

    public var sampleData: Data {
        return Data()
    }
    
}
