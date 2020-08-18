//
//  StringExt.swift
//  yintao
//
//  Created by youtuios on 2019/4/28.
//  Copyright © 2020 广州. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func labelHeight(_ maxWidth: CGFloat, font: UIFont) -> CGFloat {
        let attribute = [NSAttributedString.Key.font: font]
        return self.labelHeight(maxWidth, attributes: attribute)
    }
    
    func labelHeight(_ maxWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let string: NSString = NSString(string: self)
        let rect = string.boundingRect(with: CGSize.init(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: attributes, context: nil)
        return rect.size.height
    }
    
    func labelSize(maxHeight: CGFloat, font: UIFont) -> CGSize {
        let attribute = [NSAttributedString.Key.font: font]
        let string: NSString = NSString.init(string: self)
        let rect = string.boundingRect(with: CGSize.init(width: UIScreen.main.bounds.width, height: maxHeight), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: attribute, context: nil)
        return rect.size
    }
    
    func labelSize(maxWidth: CGFloat, font: UIFont) -> CGSize {
        let attribute = [NSAttributedString.Key.font: font]
        let string: NSString = NSString.init(string: self)
        let rect = string.boundingRect(with: CGSize.init(width: maxWidth, height:  CGFloat(MAXFLOAT)), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: attribute, context: nil)
        return rect.size
    }
    
    func labelWidth(_ maxHeight: CGFloat, font: UIFont) -> CGFloat {
        let attribute = [NSAttributedString.Key.font: font]
        let string: NSString = NSString.init(string: self)
        let rect = string.boundingRect(with: CGSize.init(width: UIScreen.main.bounds.width, height: maxHeight), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: attribute, context: nil)
        return rect.size.width
    }
    
    func toDictionary() -> [String: Any]? {
        let data = self.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    
//    func dateString() -> String {
//        let nowTime = Date().timeIntervalSince1970
//        if let timeInterval: Double = Double(self) {
//            let time = nowTime - timeInterval - 8 * 60 * 60 //减掉8小时，因为是从8点开始的
//            let date = Date(timeIntervalSince1970: time)
//            yt_dateformatter.dateFormat = "HH:mm:ss" //自定义日期格式
//            let timeString = yt_dateformatter.string(from: date)
//            return timeString
//        }
//        return ""
//    }
    
    /// 计算字符数，汉子为2字符，其他为1
    ///
    /// - Returns: 字符数
    func byteLenght() -> Int {
        var lenght = 0
        for c in self.utf16 {
            if c > 0x4e00 && c < 0x9fff {///中文
                lenght += 2
            } else {
                lenght += 1
            }
        }
        return lenght
    }
    
    ///根据限制数返回限制数所在字符串位置
    func lenghtToMax(_ max: Int) -> Int {
        var lenght = 0
        var character = 0
        for c in self.utf16 {
            if lenght >= max {
                break
            }
            character += 1
            if c > 0x4e00 && c < 0x9fff {///中文
                lenght += 2
            } else {
                lenght += 1
            }
        }
        if lenght > max && character > 0 {
            return character - 1
        }
        return character
    }
    
    // base64编码
    func toBase64() -> String {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return self
    }

    // base64解码
    func fromBase64() -> String {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8) ?? self
        }
        return self
    }
    
    func intValue() -> Int {
        return Int(self) ?? 0
    }
    
    func int64Value() -> UInt64 {
        return UInt64(self) ?? 0
    }
    
    func boolValue() -> Bool {
        return self == "1"
    }
}

extension String {
    
    enum TrimmingType {

        /// 首尾空格
        case whitespace

        /// 首尾空格和换行
        case whitespaceAndNewline
    }

    func trimming(_ trimmingType: TrimmingType) -> String {
        switch trimmingType {
        case .whitespace:
            return self.trimmingCharacters(in: CharacterSet.whitespaces)
        case .whitespaceAndNewline:
            return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    func rangeFromNSRange(range: NSRange) -> Range<String.Index>? {
        guard let from = self.utf16.index(self.utf16.startIndex, offsetBy: range.location, limitedBy: self.utf16.endIndex) else { return nil }
        guard let to = self.utf16.index(from, offsetBy: range.length, limitedBy: self.utf16.endIndex) else { return nil }
        return from ..< to
    }

    func index(from: Int) -> Index {
        return self.utf16.index(self.utf16.startIndex, offsetBy: from)
    }
    
    func substring(from: Int, to: Int) -> String {
        if (to - from) < 0 {
            return self
        }
        let start = self.index(from: from)
        let end = self.utf16.index(start, offsetBy: min(to - from, self.utf16.count))
        return String(self[start..<end])
    }

    func substring(range: NSRange) -> String {
        return substring(from: range.lowerBound, to: range.upperBound)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = self.index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = self.index(from: to)
        return String(self[..<toIndex])
    }

    func slice(from start: String, to: String) -> String? {

        if start.isEmpty {
            return (self.range(of: to, range: self.startIndex..<self.endIndex)?.lowerBound).map { eInd in
                String(self[self.startIndex..<eInd])
            }
        }

        return (self.range(of: start)?.upperBound).flatMap { sInd -> String? in
            (self.range(of: to, range: sInd..<self.endIndex)?.lowerBound).map { eInd in
                String(self[sInd..<eInd])
            }
        }
    }
    
}

