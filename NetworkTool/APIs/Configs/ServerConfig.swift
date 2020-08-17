//
//  ServerConfig.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Foundation

class ServerConfig: BaseModel {
    ///服务器 IP 或域名
    var yt_server: String?
    ///端口号
    var yt_port: Int?
    ///是否允许进入APP,这种敏感的尽量别全屏，容易被查
    var yt_canEn: Bool = true
    ///启动公告内容，如果空字符串就不需要显示
    var yt_showMsg: String?
    ///跳转链接，一般是点击公告弹窗确定按钮跳转
    var yt_jumpURL: String?
    ///协议名
    var yt_scheme: String?
    ///最新的版本
    var yt_lastV: String?
    ///是否是正式版
    var yt_release: Bool = false
}
