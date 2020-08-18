//
//  LoginResult.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/18.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Foundation

class LoginResult: BaseModel {
    ///授权码，成功时返回。之后的所有接口都应该在头部放入Authorization={{token}}
    var token: String = ""
    ///是否已经设置了密码，如果没设置密码，应该在验证码登录成功后弹出设置密码界面，一般是新注册用户才会有这一步
    var isSetPassword: Bool = true
    ///是否已经完善了资料，比如填写了昵称，性别，头像那些。如果没有，就需要登录成功后跳转到设置资料页面
    var isSetInfo: Bool = true
    ///是否已绑定手机号
    var isBindMobile: Bool = true
    ///用户ID
    var userid: String?
}
