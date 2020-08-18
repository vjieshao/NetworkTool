//
//  CdnAPI.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Moya

public enum CdnAPI: BaseAPI {
    case configuration(version: String)
}

extension CdnAPI {
    
    public var baseURL: URL {
        switch self {
        case .configuration:
            return URL(string: "https://shengjian-1258861966.image.myqcloud.com/")!
        }
    }
    
    public var path: String {
        switch self {
        case let .configuration(version):
            return "config/ios/yintao\(version).json"
        }
    }
    
    public var method: Method {
        return .get
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case .configuration:
            return ["ts": "\(Int(Date().timeIntervalSince1970))"]
        }
    }
    
}
