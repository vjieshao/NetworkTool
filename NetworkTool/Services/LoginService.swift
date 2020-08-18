//
//  LoginService.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/18.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Foundation
import RxSwift

class LoginService {
    
    private var loginService: NetworkTool = NetworkTool<LoginAPI>()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    func login(loginType: String, appVersion: String, channel: String, mobile: String, password: String, code: String, onCompleted: ((_ loginResult: LoginResult) -> Void)?, onError: ((_ error: Error) -> Void)?) {
        loginService
            .rx
            .request(.login(loginType: loginType, appVersion: appVersion, channel: channel, mobile: mobile, password: password, verifyCode: code))
            .mapObject(type: LoginResult.self)
            .subscribe(onNext: { model in
                onCompleted?(model)
            }, onError: { error in
                onError?(error)
            })
            .disposed(by: self.disposeBag)
    }
    
}
