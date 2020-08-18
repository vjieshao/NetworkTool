//
//  NetworkTool.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Moya
import RxSwift
import Alamofire
import Toast_Swift

public struct NetworkManager {

    public static var manager: Session {
        let config = URLSessionConfiguration.default
        config.sharedContainerIdentifier = "com.networking.yt.www"
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return Session(configuration: config)
    }

    public static var authPlugin: PluginType?

    public static var networkActivityPlugin: PluginType {
        let activityPlugin = NetworkActivityPlugin { change, target in
            DispatchQueue.main.async {
                switch change {
                case .began: UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended: UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
        return activityPlugin
    }
}

public class NetworkTool<Target: TargetType>: MoyaProvider<Target> {
    
    public static func endpointClosure(_ target: Target) -> Endpoint {
        let sampleResponseClosure = { return EndpointSampleResponse.networkResponse(0, target.sampleData) }
        let url: String
        if !target.path.isEmpty {
            url = target.baseURL.appendingPathComponent(target.path).absoluteString
        } else {
            url = target.baseURL.absoluteString
        }
        return Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: target.method, task: target.task, httpHeaderFields: target.headers)
    }

    init(endpointClosure: @escaping EndpointClosure = NetworkTool.endpointClosure, session: Session = NetworkManager.manager, plugins: [PluginType] = [NetworkManager.networkActivityPlugin]) {
        super.init(endpointClosure: endpointClosure, session: session, plugins: plugins)
    }
    
}

extension NetworkTool: ReactiveCompatible {}

extension Moya.Response {
    
    private struct AssociatedKeys {
        static var needToastKey = "Moya.Response.needToast"
        static var needSignKey = "Moya.Response.needSignKey"
        static var isRepeatKey = "Moya.Response.isRepeatKey"
    }

    /// 是否需要吐司
    public var needToast: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.needToastKey) as? Bool ?? false
        }
        set (manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.needToastKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否需要签名
    public var needSign: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.needSignKey) as? Bool ?? false
        }
        set (manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.needSignKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 失败后是否重新发送，重发次数再ServerConfigManager设置
    public var isRepeat: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isRepeatKey) as? Bool ?? false
        }
        set (manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.isRepeatKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

public extension Reactive where Base: MoyaProviderType {

    func request(_ token: Base.Target, needToast: Bool = true, needSign: Bool = false, isRepeat: Bool = false, callbackQueue: DispatchQueue? = nil) -> Observable<Moya.Response> {
        if isRepeat {
            return base
                    .rxRequest(token, needToast: needToast, needSign: needSign, callbackQueue: callbackQueue)
                    .retryWhen { (errors: Observable<Error>) in
                        return errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
                            return index <= ServerCommon.repeatCount ? Observable<Int64>.timer(DispatchTimeInterval.seconds(ServerCommon.repeatDelay), scheduler: MainScheduler.instance) : Observable.error(error)
                        }
                    }
        } else {
            return base.rxRequest(token, needToast: needToast, needSign: needSign, callbackQueue: callbackQueue)
        }
    }

    func requestWithProgress(_ token: Base.Target, needToast: Bool = true, needSign: Bool = false, isRepeat: Bool = false, callbackQueue: DispatchQueue? = nil, progressHandler: @escaping (Double)-> Void) -> Observable<Moya.Response> {
        if isRepeat {
            return base
                    .rxRequestWithProgress(token, needToast: needToast, needSign: needSign, callbackQueue: callbackQueue, progressHandler: progressHandler)
                    .retryWhen { (errors: Observable<Error>) in
                        return errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
                            return index <= ServerCommon.repeatCount ? Observable<Int64>.timer(DispatchTimeInterval.seconds(ServerCommon.repeatDelay), scheduler: MainScheduler.instance) : Observable.error(error)
                        }
                    }
        } else {
            return base.rxRequestWithProgress(token, needToast: needToast, needSign: needSign, callbackQueue: callbackQueue, progressHandler: progressHandler)
        }
    }
    
}

internal extension MoyaProviderType {

    func rxRequest(_ token: Target, needToast: Bool = true, needSign: Bool = false, callbackQueue: DispatchQueue? = nil) -> Observable<Moya.Response> {
        return Observable.create { [weak self] observer in
            let cancellableToken = self?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    response.needSign = needSign
                    response.needToast = needToast
                    observer.onNext(response)
                    observer.onCompleted()

                case let .failure(error):
                    // response.response 为空的时候 error 是 underlying(error)
                    switch error {
                    case .underlying(let error as NSError, _):
                        if !(error.localizedDescription.contains("network") || error.localizedDescription.contains("time out") || error.localizedDescription.contains("网络连接已中断")) {
                            if error.localizedDescription.contains("JSON could not be") {
                                UIApplication.shared.keyWindow?.makeToast("服务器异常，请稍后再试", duration: 2, position: .center)
                            } else if error.localizedDescription.contains("未能找到") {
                                UIApplication.shared.keyWindow?.makeToast("网络异常连接服务器失败，请切换网络后重试。", duration: 2, position: .center)
                            } else if error.code != -999 {
                                UIApplication.shared.keyWindow?.makeToast("\(error.localizedDescription),code:\(error.code)", duration: 2, position: .center)
                            }
                        }
                        let error = NetworkError(code: error.code, failureReason: error.localizedDescription + " " + "\(error.code)", url: token.baseURL, raw: error)
                        observer.onError(error)
                        
                    default:
                        let error = NetworkError(code: error.errorCode, failureReason: error.failureReason ?? (error.errorDescription ?? "未知错误"), url: token.baseURL, raw: error)
                        observer.onError(error)
                    }
                }
            }

            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }

    func rxRequestWithProgress(_ token: Target, needToast: Bool = true, needSign: Bool = false, callbackQueue: DispatchQueue? = nil, progressHandler: @escaping (Double)-> Void) -> Observable<Response> {

        let response: Observable<Response> = Observable.create { [weak self] observer in

            let cancellableToken = self?.request(token, callbackQueue: callbackQueue, progress: { (progressResponse: ProgressResponse) in
                progressHandler(progressResponse.progress)
            }, completion: { result in
                switch result {
                case let .success(response):
                    response.needSign = needSign
                    response.needToast = needToast
                    observer.onNext(response)
                    observer.onCompleted()
                    
                case let .failure(error):
                    // response.response 为空的时候 error 是 underlying(error)
                    switch error {
                    case .underlying(let error as NSError, _):
                        if !(error.localizedDescription.contains("network") || error.localizedDescription.contains("time out") || error.localizedDescription.contains("网络连接已中断")) {
                            if error.localizedDescription.contains("JSON could not be") {
                                UIApplication.shared.keyWindow?.makeToast("服务器异常，请稍后再试", duration: 2, position: .center)
                            } else if error.localizedDescription.contains("未能找到") {
                                UIApplication.shared.keyWindow?.makeToast("网络异常连接服务器失败，请切换网络后重试。", duration: 2, position: .center)
                            } else if error.code != -999 {
                                UIApplication.shared.keyWindow?.makeToast("\(error.localizedDescription),code:\(error.code)", duration: 2, position: .center)
                            }
                        }
                        let error = NetworkError(code: error.code, failureReason: error.localizedDescription + " " + "\(error.code)", url: token.baseURL, raw: error)
                        observer.onError(error)
                        
                    default:
                        let error = NetworkError(code: error.errorCode, failureReason: error.failureReason ?? (error.errorDescription ?? "未知错误"), url: token.baseURL, raw: error)
                        observer.onError(error)
                    }
                }
            })

            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
        return response
    }
    
}
