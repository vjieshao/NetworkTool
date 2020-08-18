//
//  DateExt.swift
//  yintao
//
//  Created by 龙家辉 on 2019/4/18.
//  Copyright © 2020 广州. All rights reserved.
//

import Foundation

extension Date {
//    static func date(year: Int, month: Int, day: Int) -> Date?{
//        var components = DateComponents()
//        components.year = year
//        components.month = month
//        components.day = day
//        return yt_calendar.date(from: components)
//    }
//    ///获取当前时间的小时数
//    func getHour() -> Int {
//        return yt_calendar.component(.hour, from: self)
//    }
//    ///获取当前时间的分钟数
//    func getMinute() -> Int {
//        return yt_calendar.component(.minute, from: self)
//    }
//    
//    func timeString(_ dateFormat: String = "yyyy.MM.dd HH:mm:ss") -> String {
//        yt_dateformatter.dateFormat = dateFormat //自定义日期格式
//        return yt_dateformatter.string(from: self)
//    }
    
    func getServerNowTime() -> TimeInterval {
        return self.timeIntervalSince1970
//        return self.timeIntervalSince1970 - Defaults[.serverTimeChange]
    }
    
}
