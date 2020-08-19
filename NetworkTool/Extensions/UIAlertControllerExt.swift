//
//  UIAlertControllerExt.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/19.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    class func alert(_ title: String?, message: String?, messageAlignment: NSTextAlignment = .center, hasCloseBtn: Bool = false, cancelTitle: String = "取消", cancelColor: UIColor = UIColor.purple, sureTitle: String = "确定", sureColor: UIColor = UIColor.white, enableClickEmpty: Bool = true, mustPresent: Bool = true, controller: UIViewController? = nil, sureComplection: ((YTAlertAction)->Void)?, cancelComplection: ((YTAlertAction)->Void)? = nil) {
        
        let alert = YTAlertController.init(title: title, message: message, messageAlignment: messageAlignment, hasCloseBtn: hasCloseBtn, enableClickEmpty: enableClickEmpty, style: .alert)
        if cancelTitle.count > 0 {
            let cancelAction = YTAlertAction.init(title: cancelTitle, titleColor: UIColor.black.withAlphaComponent(0.6), backgroundColor: UIColor.white, borderWidth: 0.5, borderColor: UIColor.colorRGB(0xEEEEEE)) { (cancelAction) in
                if cancelComplection != nil {
                    cancelComplection!(cancelAction)
                }
            }
            alert.addAction(cancelAction)
        }
        let sureAction = YTAlertAction.init(title: sureTitle, titleColor: sureColor, backgroundColor: UIColor.purple, borderWidth: 0, borderColor: nil) { (sureAction) in
            if sureComplection != nil {
                sureComplection!(sureAction)
            }
        }
        alert.addAction(sureAction)
        alert.modalPresentationStyle = .overFullScreen
        if controller != nil {
            controller?.present(alert, animated: false, completion: nil)
        } else if mustPresent {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: false, completion: nil)
        }
    }

}
