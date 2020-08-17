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
        let sampleResponseClosure = { return EndpointSampleResponse.networkResponse(200, target.sampleData) }
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

public extension Reactive where Base: MoyaProviderType {

    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Observable<Response> {
        return base.rxRequest(token, callbackQueue: callbackQueue)
    }

    func requestWithProgress(_ token: Base.Target, callbackQueue: DispatchQueue? = nil, progressHandler: @escaping (Double)-> Void) -> Observable<Response> {
        return base.rxRequestWithProgress(token, callbackQueue: callbackQueue, progressHandler: progressHandler)
    }
    
}

internal extension MoyaProviderType {

    func rxRequest(_ token: Target, callbackQueue: DispatchQueue? = nil) -> Observable<Moya.Response> {
        return Observable.create { [weak self] observer in
            let cancellableToken = self?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()

                case let .failure(error):

                    // response.response 为空的时候 error 是 underlying(error)
                    switch error {
                    case .underlying(let error as NSError, _):
                        break
                        // 错误码大全：https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSURLError.swift
//                        let providerError = ProviderError(code: error.code, failureReason: error.localizedDescription + " " + "\(error.code)", url: token.baseURL)
//                        observer.onError(providerError)
                    default:
                        observer.onError(error)
                    }
                }
            }

            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }

    func rxRequestWithProgress(_ token: Target, callbackQueue: DispatchQueue? = nil, progressHandler: @escaping (Double)-> Void) -> Observable<Response> {

        let response: Observable<Response> = Observable.create { [weak self] observer in

            let cancellableToken = self?.request(token, callbackQueue: callbackQueue, progress: { (progressResponse: ProgressResponse) in
                progressHandler(progressResponse.progress)
            }, completion: { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()
                case let .failure(error):
                    switch error {
                    case let .underlying(error as NSError, _):
                        break
//                        let providerError = ProviderError(code: error.code, failureReason: error.localizedDescription + " " + "\(error.code)", url: token.baseURL)
//                        observer.onError(providerError)
                    default:
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
