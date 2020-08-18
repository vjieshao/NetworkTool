//
//  BaseModel.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/17.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import UIKit
import HandyJSON

class BaseModel: NSObject, HandyJSON {
    var code: Int?
    var msg: String?
    var _sign: String?
    var tipType: String?
    required override init() {}
}
