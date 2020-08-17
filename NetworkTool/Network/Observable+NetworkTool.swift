//
//  Observable+NetworkTool.swift
//  NetworkTool
//
//  Created by 黄杰 on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Moya
import RxSwift
import HandyJSON

extension Observable where Element == Moya.Response {

    public func mapJSON() -> Observable<[String: Any]> {
        return map { response in
            try response.validStatusCode()
            guard let mapedJSON = try? response.mapJSON() as? [String: Any] else {
                throw try response.handleError(ProviderError.jsonSerializationFailed(of: response.response?.url))
            }
            return mapedJSON
        }
    }

    public func mapJSONs() -> Observable<[[String: Any]]> {
        return map { response in
            try response.validStatusCode()
            guard let mapedJSON = try? response.mapJSON() as? [[String: Any]] else {
                throw try response.handleError(ProviderError.jsonSerializationFailed(of: response.response?.url))
            }
            return mapedJSON
        }
    }

    public func mapResult() -> Observable<Bool> {
        return map { response in
            try response.validStatusCode()
            return true
        }
    }
    
    public func mapObject<T: HandyJSON>(type: T.Type) -> Observable<T> {

        return map { response in

            try response.validStatusCode()

            let mapedJSON = try response.mapJSON() as? [String: Any]
            
            guard let object = type.deserialize(from: mapedJSON) else {
                throw ProviderError.generationObjectFailed(of: response.response?.url)
            }
            return object
        }
    }

    public func mapObjects<T: HandyJSON>(type: T.Type, key: String? = nil) -> Observable<[T]> {

        return map { response in

            try response.validStatusCode()

            let mapedJSON = try response.mapJSON()

            if let key = key {

                var results: [[String: Any]]?

                if let json = mapedJSON as? [String: Any], let resultsBuffer = json[key] as? [[String: Any]] {
                    results = resultsBuffer
                } else if let jsons = mapedJSON as? [[String: Any]] {
                    results = jsons.compactMap { $0[key] as? [String: Any] }
                }

                guard let unwrappedResults = results else {
                    throw ProviderError.jsonSerializationFailed(of: response.response?.url)
                }
                return unwrappedResults.compactMap { type.deserialize(from: $0) }

            } else {
                guard let jsons = mapedJSON as? [[String: Any]] else {
                    throw ProviderError.jsonSerializationFailed(of: response.response?.url)
                }
                return jsons.compactMap { type.deserialize(from: $0) }
            }
        }
    }
    
}

extension Moya.Response {

    fileprivate func validStatusCode() throws {

//        print(try? mapJSON())
//        print(try? mapString())

        let url = response?.url

        if let json = try? mapJSON(), let unwrappedJSON = json as? [String: Any] {

            var errorCode = unwrappedJSON["error_code"] as? Int ?? unwrappedJSON["code"] as? Int
            let message = unwrappedJSON["error_message"] as? String ?? unwrappedJSON["message"] as? String

            if let errorCodeStr = unwrappedJSON["error_code"] as? String, let code = Int(errorCodeStr) {
                errorCode = code
            }

            if let unwrappedErrorCode = errorCode, unwrappedErrorCode != 0, let unwrappedMessage = message {
                if let response = response {
                    print("💥💥💥 无效访问 \(response)")
                }
                print("\nGot error message: \(unwrappedJSON)")
                throw ProviderError(code: unwrappedErrorCode, failureReason: unwrappedMessage, url: url, raw: unwrappedJSON)
            }
        }

        if !((200...399) ~= statusCode) {
            if let response = response {
                print("💥💥💥 无效访问 \(response)")
            }
            if statusCode >= 500 {
                throw ProviderError(code: 444409, failureReason: "服务器失联了...\(statusCode)", url: url)
            }
            throw ProviderError(code: statusCode, failureReason: HTTPURLResponse.localizedString(forStatusCode: statusCode), url: url, raw: self)
        }
    }

    fileprivate func handleError(_ error: Error) throws -> Error {
        if let response = response {
            print("💥💥💥 无效访问 \(response)")
            if let json = try? mapJSON(), let unwrappedJSON = json as? [String: Any] {
                print("\nGot error message: \(unwrappedJSON)")
            } else if let string = try? mapString() {
                print("\nGot error message: \(error) \n\(string)")
            }
        }
        return error
    }
}
