//
//  UIColorExt.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/19.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func colorRGB(_ value:UInt32) -> (UIColor) {
        let color = UIColor.init(red: (((CGFloat)((value & 0xFF0000) >> 16)) / 255.0), green: (((CGFloat)((value & 0xFF00) >> 8)) / 255.0), blue: ((CGFloat)(value & 0xFF) / 255.0), alpha: 1)
        return color
    }

}
