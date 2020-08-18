//
//  AppDelegate.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// 获取配置信息
        if let infoDictionary = Bundle.main.infoDictionary, let majorVersion: String = infoDictionary ["CFBundleShortVersionString"] as? String {
            ServerConfigManager.shared().getConfig(majorVersion, onComplection: { config in
                print(config)
            })
        }
        
        return true
    }


}

