//
//  UIViewExt.swift
//  NetworkTool
//
//  Created by guangzhouyoutu on 2020/8/19.
//  Copyright © 2020 guangzhouyoutu. All rights reserved.
//

import UIKit

class YTBgView: UIView {
}

extension UIView {

    func addRounded(corners: UIRectCorner, radius: CGFloat) {
        self.addRounded(corners: corners, radii: CGSize(width: radius, height: radius))
    }
    
    func addRounded(corners: UIRectCorner, radii: CGSize, borderWidth: CGFloat? = nil, borderColor: UIColor? = nil) {
        if self.bounds.size.equalTo(CGSize.zero){
            //debugPrint("[warn](IN ADDROUNDED UIViewExt.swift) view的bounds为CGSize.zero")
            return
        }
        
        if corners != .allCorners || self.isKind(of: UILabel.self) || self.isKind(of: UIButton.self) {
            let rounded = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radii)
            if let borderColor = borderColor, let borderWidth = borderWidth {
                if let sublayers = self.layer.sublayers {
                    for layer in sublayers {
                        if layer.isKind(of: CAShapeLayer.self) {
                            layer.removeFromSuperlayer()
                        }
                    }
                }
                let temp = CAShapeLayer()
                temp.fillColor = UIColor.clear.cgColor
                temp.strokeColor = borderColor.cgColor
                temp.lineWidth = borderWidth
                temp.frame = self.bounds
                temp.path = rounded.cgPath
                self.layer.addSublayer(temp)
            }
            let shape = CAShapeLayer.init()
            shape.path = rounded.cgPath
            self.layer.mask = shape
        } else {
            self.layer.cornerRadius = min(radii.width, radii.height)
            if !self.isKind(of: YTBgView.self) {
                self.layer.masksToBounds = true
            }
            if let borderColor = borderColor, let borderWidth = borderWidth {
                self.layer.borderColor = borderColor.cgColor
                self.layer.borderWidth = borderWidth
            }
        }
    }
    
    func addRound(_ leftTop: CGFloat, leftBottom: CGFloat, rightTop: CGFloat, rightBottom: CGFloat) {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        
        //获取四个圆心
        let topLeftCenterX = minX +  leftTop
        let topLeftCenterY = minY + leftTop
         
        let topRightCenterX = maxX - rightTop
        let topRightCenterY = minY + rightTop
        
        let bottomLeftCenterX = minX + leftBottom
        let bottomLeftCenterY = maxY - leftBottom
         
        let bottomRightCenterX = maxX -  rightBottom
        let bottomRightCenterY = maxY - rightBottom
        
        //虽然顺时针参数是YES，在iOS中的UIView中，这里实际是逆时针
        let path :CGMutablePath = CGMutablePath();
         //顶 左
        path.addArc(center: CGPoint(x: topLeftCenterX, y: topLeftCenterY), radius: leftTop, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: false)
        //顶右
        path.addArc(center: CGPoint(x: topRightCenterX, y: topRightCenterY), radius: rightTop, startAngle: CGFloat.pi * 3 / 2, endAngle: 0, clockwise: false)
        //底右
        path.addArc(center: CGPoint(x: bottomRightCenterX, y: bottomRightCenterY), radius: rightBottom, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: false)
        //底左
        path.addArc(center: CGPoint(x: bottomLeftCenterX, y: bottomLeftCenterY), radius: leftBottom, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: false)
        path.closeSubpath();
        
        let shapLayer = CAShapeLayer()
        shapLayer.frame = self.bounds
        shapLayer.path = path
        self.layer.mask = shapLayer
    }
    
}
