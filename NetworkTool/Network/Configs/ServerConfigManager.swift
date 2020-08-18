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
    
    /// 是否为开发人员
    var isDeveloper: Bool = false

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
    
    /// 或者配置根目录
    func getRootPath() -> String? {
        if var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last {
            path.append("/config")
            //debugPrint(path)
            if !FileManager.default.fileExists(atPath: path) {
                do{
                    try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return nil
                }
            }
            return path
        }
        return nil
    }
    
    ///是否需要请求配置
    func needRequestConfig() -> Bool {
        if let path = self.getRootPath() {
            if FileManager.default.fileExists(atPath: "\(path)/config.json") {///有开发人员的配置，直接使用,不需要请求
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    /// 获取配置
    func getConfig(_ version: String, onComplection: ((_ config: ServerConfig) -> Void)?, onError: ((_ error: Error) -> Void)? = nil) {
        if var path = self.getRootPath() {
            path.append("/config.json")
            if FileManager.default.fileExists(atPath: path) {///有开发人员的配置，直接使用
                self.isDeveloper = true
                if let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) {
                    if let json = String.init(data: data, encoding: .utf8) {
                        //debugPrint(json)
                        if let server = ServerConfig.deserialize(from: json) {
                            self.serverConfig = server
                            DispatchQueue.main.async {
                                onComplection?(server)
                            }
                        }
                    }
                }
            } else {
                self.requestConfig(version, onComplection: onComplection, onError: onError)
            }
        }
    }
    /// 保存开发配置
    func saveDeveloperConfig(_ server: String, port: Int) {
        self.serverConfig.yt_server = server
        self.serverConfig.yt_port = port
        
        let json = self.serverConfig.toJSONString()
        if var path = self.getRootPath() {
            path.append("/config.json")
            self.isDeveloper = true
            if let data = json?.data(using: .utf8) {
                try? data.write(to: URL.init(fileURLWithPath: path), options: .atomic)
            }
        }
    }
    ///移除开发配置
    func yt_clearDeveloperConfig() {
        if var path = self.getRootPath() {
            path.append("/config.json")
            if FileManager.default.fileExists(atPath: path) {
                try? FileManager.default.removeItem(atPath: path)
                if let infoDictionary = Bundle.main.infoDictionary, let majorVersion: String = infoDictionary ["CFBundleShortVersionString"] as? String {
                    self.requestConfig(majorVersion)
                }
            }
        }
    }
    
    /// 请求配置
    func requestConfig(_ version: String, onComplection: ((_ config: ServerConfig) -> Void)? = nil, onError: ((_ error: Error) -> Void)? = nil) {
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
