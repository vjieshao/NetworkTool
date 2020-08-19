//
//  DateExt.swift
//  yintao
//
//  Created by 龙家辉 on 2019/4/18.
//  Copyright © 2020 广州. All rights reserved.
//

import Foundation

extension Date {
    
    func getServerNowTime() -> TimeInterval {
        return self.timeIntervalSince1970
//        return self.timeIntervalSince1970 - Defaults[.serverTimeChange]
    }
    
}
