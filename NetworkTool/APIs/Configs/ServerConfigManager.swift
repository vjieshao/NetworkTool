//
//  ServerConfigManager.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import UIKit

enum Host {
    case api(_ config: ServerConfig)
    case host(_ config: ServerConfig)
    
    var host: String {
        switch self {
        case let .api(config), let .host(config):
            var host = "\(config.yt_server ?? ServerCommon.apiServer)"
            if !host.contains("http") {
                if let scheme = config.yt_scheme {
                    host = "\(scheme)://\(host)"
                } else {
                    if config.yt_port == 443 {
                        host = "https://\(host)"
                    } else {
                        host = "http://\(host)"
                    }
                }
            }
            var apiHost = ""
            if let port = config.yt_port {
                switch self {
                case .api:
                    apiHost = "\(host):\(port)/api/"
                case .host:
                    apiHost = "\(host):\(port)/"
                }
            } else {
                switch self {
                case .api:
                    apiHost = "\(host)/api/"
                case .host:
                    apiHost = "\(host)/"
                }
            }
            return apiHost
        }
    }
}

struct ServerCommon {
    static let repeatCount = 5 //配置最高失败重新请求次数
    ///默认线上服务器
    static let apiServer = "https://app.imyintao.com"
}

class ServerConfigManager: NSObject {

    static func shared() -> ServerConfigManager {
        return self.manager
    }
    
    private static let manager = ServerConfigManager()
    
    /// 配置信息
    private var serverConfig = ServerConfig()
    
    /// 获取apiHost
    func getApiHost() -> String {
        return Host.api(self.serverConfig).host
    }
    
    /// 获取host
    func getHost() -> String {
        return Host.host(self.serverConfig).host
    }
    
    /// 获取header
    func getHeader() -> [String: String] {
        let token = ""
        var assigned: [String: String] = [:]
        if token.count > 0 {
            assigned["Authorization"] = token
        } else {
            
        }
        return assigned
    }
    
}
