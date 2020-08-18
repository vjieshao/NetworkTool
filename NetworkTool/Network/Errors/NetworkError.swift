//
//  NetworkError.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/18.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Foundation
import UIKit

public enum NetworkErrorCode: Int {
    /// token失效
    case invalidAuthToken = -99999
    
    /// token过期
    case expiredAuthToken = -46
    
    /// 未知错误
    case unknown = 440404
    
    /// json解析错误
    case jsonSerializationFailed = 440407
}

public struct NetworkError: Swift.Error {
    
    public let code: NetworkErrorCode
    public let failureReason: String
    public let raw: Any?
    
    public init(code: Int, failureReason: String, url: URL? = nil, raw: Any? = nil) {
        self.raw = raw
        self.code = NetworkErrorCode(rawValue: code) ?? NetworkErrorCode.unknown
        self.failureReason = failureReason
    }
    
    public static func jsonSerializationFailed(of url: URL?) -> NetworkError {
        return NetworkError(code: NetworkErrorCode.jsonSerializationFailed.rawValue, failureReason: "解析失败", url: url)
    }
    
    public static func jsonUnknowFailed(of url: URL?) -> NetworkError {
        return NetworkError(code: NetworkErrorCode.unknown.rawValue, failureReason: "无效访问", url: url)
    }
    
}

extension Error {
    
    public func handleError() {
        if let error = self as? NetworkError {
            UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 1.6, position: .center)
        } else {
            UIApplication.shared.keyWindow?.makeToast(self.localizedDescription, duration: 1.6, position: .center)
        }
    }
    
}
