//
//  LoginAPI.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/18.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Moya

public enum LoginAPI: BaseAPI {
    /// 登录
    case login(loginType: String, appVersion: String, channel: String, mobile: String, password: String, verifyCode: String)
}

extension LoginAPI {
    
    public var path: String {
        switch self {
        case .login:
            return "login"
        }
    }
    
    public var method: Method {
        return .post
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case let .login(loginType, appVersion, channel, mobile, password, verifyCode):
            return ["loginType": loginType, "appVersion": appVersion, "channel": channel, "mobile": mobile, "password": password, "verifyCode": verifyCode]
        }
    }
    
}

