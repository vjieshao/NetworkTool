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
import CryptoSwift

let yt_a1k1 = "MzRaamtsYQ=="
let yt_x3l3 = "c2QkMDhhamg="
let yt_h2n2 = "QTkwP2RrRWQ="

extension Observable where Element == Moya.Response {

    public func mapJSON() -> Observable<[String: Any]> {
        return map { response in
            try response.validStatusCode()
            guard let mapedJSON = try? response.mapJSON() as? [String: Any] else {
                let error = NetworkError.jsonSerializationFailed(of: response.response?.url)
                if response.needToast {
                    UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
                }
                throw try response.handleError(error)
            }
            return mapedJSON
        }
    }

    public func mapJSONs() -> Observable<[[String: Any]]> {
        return map { response in
            try response.validStatusCode()
            guard let mapedJSON = try? response.mapJSON() as? [[String: Any]] else {
                let error = NetworkError.jsonSerializationFailed(of: response.response?.url)
                if response.needToast {
                    UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
                }
                throw try response.handleError(error)
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
                let error = NetworkError.jsonSerializationFailed(of: response.response?.url)
                if response.needToast {
                    UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
                }
                throw try response.handleError(error)
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
                    let error = NetworkError.jsonSerializationFailed(of: response.response?.url)
                    if response.needToast {
                        UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
                    }
                    throw try response.handleError(error)
                }
                return unwrappedResults.compactMap { type.deserialize(from: $0) }

            } else {
                guard let jsons = mapedJSON as? [[String: Any]] else {
                    let error = NetworkError.jsonSerializationFailed(of: response.response?.url)
                    if response.needToast {
                        UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
                    }
                    throw try response.handleError(error)
                }
                return jsons.compactMap { type.deserialize(from: $0) }
            }
        }
    }
    
}

extension Moya.Response {

    fileprivate func validStatusCode() throws {

        let url = response?.url

        if let json = try? mapJSON(), let unwrappedJSON = json as? [String: Any], let model = BaseModel.deserialize(from: unwrappedJSON) {
            if let code = model.code, code < 0 && model.msg != nil {
                if self.needToast {
                    if let type = model.tipType, type == "alert" {
                        if let userid: String = unwrappedJSON["userid"] as? String {
//                            UIAlertController.alert("温馨提示", message: model.msg, cancelTitle: "反馈", sureComplection: { _ in
//                            }, cancelComplection: { _ in
////                                let model = YTFeedbackUploadModel()
////                                model.type = YTFeedbackType.appeal.rawValue
////                                model.userid = userid
////                                model.reason = dict?.msg
////                                let vc = YTFeedbackViewController.init(model)
////                                YTUtils.gotoViewController(vc)
//                            })
                        } else {
//                            UIAlertController.alert("温馨提示", message: model.msg, cancelTitle: "", sureTitle: "我知道了", sureComplection: nil)
                        }
                    } else {
                        if model.code == -99999 || model.code == -46 {
                            if let userid: String = unwrappedJSON["userid"] as? String {
//                                UIAlertController.alert("温馨提示", message: model.msg, cancelTitle: "反馈", sureComplection: { _ in
//                                    if url?.absoluteString.contains("isRegist") ?? false {
////                                        let vc = YTVerifyViewController.init(.login, verifyType: .verifyPassword)
////                                        YTUtils.gotoViewController(vc)
//                                    }
//                                }, cancelComplection: { _ in
////                                    let model = YTFeedbackUploadModel()
////                                    model.type = YTFeedbackType.appeal.rawValue
////                                    model.userid = userid
////                                    model.reason = dict?.msg
////                                    let vc = YTFeedbackViewController.init(model)
////                                    YTUtils.gotoViewController(vc)
//                                })
                            } else {
//                                UIAlertController.alert("温馨提示", message: model.msg, sureComplection: nil)
                            }
                        } else {
                            if !((model.msg?.contains("network") ?? false) || (model.msg?.contains("time out") ?? false)) {
                                if (model.msg?.contains("token已失效") ?? false) {
                                    UIApplication.shared.keyWindow?.makeToast("请重新登录", duration: 2, position: .center)
                                } else {
                                    UIApplication.shared.keyWindow?.makeToast(model.msg, duration: 2, position: .center)
                                }
                            }
                        }
                    }

                }
                if let errorCode = NetworkErrorCode(rawValue: code), (errorCode == .invalidAuthToken || errorCode == .expiredAuthToken) {
                    // 跳转到登录界面
                    
                }
                throw NetworkError(code: code, failureReason: model.msg ?? "网络请求错误，未返回msg信息", url: url, raw: unwrappedJSON)
            } else {
                if needSign && model._sign == nil {
                    if self.needToast {
                        UIApplication.shared.keyWindow?.makeToast("签名不正确", duration: 2, position: .center)
                    }
                    throw NetworkError(code: model.code ?? 400989, failureReason: model.msg ?? "签名不正确", url: url, raw: unwrappedJSON)
                }
                if needSign, let sign = model._sign, !self.checkData(unwrappedJSON, sign: sign) {
                    if self.needToast {
                        UIApplication.shared.keyWindow?.makeToast("签名不正确", duration: 2, position: .center)
                    }
                    throw NetworkError(code: model.code ?? 400989, failureReason: model.msg ?? "签名不正确", url: url, raw: unwrappedJSON)
                }
            }
        } else if !((200...399) ~= statusCode) {
            if let response = response {
                print("💥💥💥 无效访问 \(response)")
            }
            if statusCode >= 500 {
                let error = NetworkError(code: 444409, failureReason: "无效访问...\(statusCode)", url: url)
                if self.needToast {
                    UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
                }
                throw error
            }
            let error = NetworkError(code: statusCode, failureReason: HTTPURLResponse.localizedString(forStatusCode: statusCode), url: url, raw: self)
            if self.needToast {
                UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
            }
            throw error
        } else {
            let error = NetworkError.jsonUnknowFailed(of: url)
            if self.needToast {
                UIApplication.shared.keyWindow?.makeToast(error.failureReason, duration: 2, position: .center)
            }
            throw try self.handleError(error)
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
    
    private func checkData(_ parameters: [String: Any]?, sign: String) -> Bool {
        let k = yt_a1k1.fromBase64() + yt_x3l3.fromBase64() + yt_h2n2.fromBase64()
        var stringA = ""
        if let param = parameters {
            var keys = param.keys.sorted()
            if keys.contains("_sign"), let index = keys.firstIndex(of: "_sign") {
                keys.remove(at: index)
            }
            if keys.contains("_ts"), let _ts: TimeInterval = param["_ts"] as? TimeInterval {
                let nowTime = Date().getServerNowTime()
//                if nowTime - _ts < -5 {
//                    LogManager.shared().addLog("checkDataFailTimeOut,nowTime:\(nowTime),ts:\(_ts), parameters:\(parameters)")
//                    return false
//                }
                if nowTime - _ts > 30 {
//                        YTLogManager.shared().addLog("checkDataFailTimeOut,nowTime:\(nowTime),ts:\(_ts), parameters:\(parameters)")
                    UIApplication.shared.keyWindow?.makeToast("请求已失效", duration: 2, position: .center)
                    return false
                }
            }
            for (index,key) in keys.enumerated() {
                if let value = param[key] {
                    if index == 0 {
                        stringA.append(key + "=")
                        stringA.append(self.changeToJson(value))
                    } else {
                        stringA.append("&")
                        stringA.append(key + "=")
                        stringA.append(self.changeToJson(value))
                    }
                }
            }
        }
        var stringSignTemp = ""
        if stringA.count > 0 {
            stringSignTemp = stringA + "&key=\(k)"
        } else {
            stringSignTemp = "key=\(k)"
        }
        let localSign = stringSignTemp.md5().uppercased()
        if localSign == sign {
//                YTLogManager.shared().addLog("checkDataSuccess, parameters:\(parameters),localSign:\(localSign)")
            return true
        } else {
//                YTLogManager.shared().addLog("checkDataFail, parameters:\(parameters),localSign:\(localSign)")
            UIApplication.shared.keyWindow?.makeToast("请求失败", duration: 2, position: .center)
            return false
        }
    }
    
    func changeToJson(_ info: Any) -> String {
        //首先判断能不能转换
        guard JSONSerialization.isValidJSONObject(info) else {
//            YTDebugLog(info)
            return "\(info)"
        }
        //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
        let jsonData = try? JSONSerialization.data(withJSONObject: info, options: [])
        if let jsonData = jsonData {
            let str = String(data: jsonData, encoding: String.Encoding.utf8)
            return str ?? "\(info)"
        }else {
            return "\(info)"
        }
    }
    
}
