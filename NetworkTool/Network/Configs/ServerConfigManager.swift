//
//  ServerConfigManager.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import UIKit
import RxSwift

enum Host {
    /// 获取带/api的host
    case api(_ config: ServerConfig)
    /// 获取host
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
    /// 配置最高失败重新请求次数
    static let repeatCount = 5
    /// 配置每次重试时间
    static let repeatDelay = 3
    /// 默认线上服务器
    static let apiServer = "https://app.imyintao.com"
}

class ServerConfigManager: NSObject {

    static func shared() -> ServerConfigManager {
        return self.manager
    }
    
    private static let manager = ServerConfigManager()
    
    /// 配置信息
    private var serverConfig = ServerConfig()
    
    /// CDN网络请求类
    private lazy var cdnNetworkService = NetworkTool<CdnAPI>()
    
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
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

// MARK: - Data Handler

extension ServerConfigManager {
    
    /// 获取配置
    func getConfig(_ version: String, onComplection: ((_ config: ServerConfig) -> Void)?, onError: ((_ error: Error) -> Void)? = nil) {
        cdnNetworkService
            .rx
            .request(.configuration(version: version), isRepeat: true)
            .mapObject(type: ServerConfig.self)
            .subscribe(onNext: { model in
                onComplection?(model)
            }, onError: { error in
                onError?(error)
            })
            .disposed(by: self.disposeBag)
    }
    
}
