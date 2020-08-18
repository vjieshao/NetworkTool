//
//  ViewController.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var loginService = LoginService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func loginAction(_ sender: Any) {
        loginService.login(loginType: "password", appVersion: "1.6.2", channel: "iOS", mobile: "18042831819", password: "a123456", code: "8888", onCompleted: { loginResult in
            print(loginResult)
        }, onError: { error in
            print(error)
        })
    }
    
}

