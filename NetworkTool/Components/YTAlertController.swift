//
//  SJAlertControllerViewController.swift
//  yintao
//
//  Created by youtuios on 2019/9/10.
//  Copyright © 2020 广州. All rights reserved.
//

import UIKit
import SnapKit

typealias YTEmptyBlock = (()->())

let yt_kSafeBottomHeight: CGFloat = ((UIApplication.shared.statusBarFrame.height > 20) ? 34 : 0)

enum YTAlertStyle {
    case alert
    case actionSheet
}

class YTAlertController: UIViewController {
    
    var alertTitle: String?
    
    var message: String?
    
    var style: YTAlertStyle = .alert
    
    var actions = [YTAlertAction]()
    
    var hasCloseBtn: Bool = false
    
    var enableClickEmpty: Bool = false
    
    var animationDuration: Double = 0.25
    
    var messageAlignment: NSTextAlignment = .center
    
    init(title: String?, message: String?, messageAlignment: NSTextAlignment = .center, hasCloseBtn: Bool = false, enableClickEmpty: Bool = false, style: YTAlertStyle) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.hasCloseBtn = hasCloseBtn
        self.enableClickEmpty = enableClickEmpty
        self.style = style
        self.messageAlignment = messageAlignment
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var baseView: UIView = {
        let baseView = UIView()
//        baseView.layer.masksToBounds = true
        return baseView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 14.0)
        messageLabel.textColor = UIColor.colorRGB(0x2C2C2C)
        messageLabel.textAlignment = self.messageAlignment
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    
    lazy var closeBtn: UIButton = {
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.setImage(UIImage.init(named: "homeClose"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return closeBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.65)
        if enableClickEmpty {
            self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_:))))
        }
        
        let baseWidth = UIScreen.main.bounds.width - 38 * 2
        self.view.addSubview(baseView)
        if self.style == .alert {
            baseView.layer.cornerRadius = 12
            baseView.backgroundColor = UIColor.white
            baseView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(baseWidth)
            }
        } else if self.style == .actionSheet {
            self.view.alpha = 0
            baseView.backgroundColor = UIColor.colorRGB(0xF8F8F8)
            baseView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(self.view.snp.bottom)
                make.width.equalToSuperview()
            }
        }
        
        if self.alertTitle?.count ?? 0 > 0 {
            baseView.addSubview(titleLabel)
            titleLabel.text = self.alertTitle
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(52)
                make.right.equalTo(-52)
                make.top.equalTo(16)
            }
        }
        if self.message?.count ?? 0 > 0 {
            baseView.addSubview(messageLabel)
            messageLabel.text = self.message
            messageLabel.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                if self.alertTitle?.count ?? 0 > 0 {
                    make.top.equalTo(titleLabel.snp.bottom).offset(12)
                } else {
                    make.top.equalTo(16)
                }
            }
        }
        
        if self.hasCloseBtn {
            baseView.addSubview(closeBtn)
            closeBtn.snp.makeConstraints { (make) in
                make.size.equalTo(44)
                make.right.equalTo(0)
                make.top.equalTo(0)
            }
        }
        if actions.count > 0 {
            let width = ((baseWidth - 32) - CGFloat(actions.count - 1) * 16)/CGFloat(actions.count)
            for (index,action) in actions.enumerated() {
                let btn = UIButton.init(type: .custom)
                btn.setTitle(action.title, for: .normal)
                btn.setTitleColor(action.titleColor, for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
                btn.backgroundColor = action.backgroundColor
                btn.layer.borderColor = action.borderColor?.cgColor
                btn.layer.borderWidth = action.borderWidth
                btn.tag = 100 + index
                btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
                baseView.addSubview(btn)
                if self.style == .alert {
                    btn.layer.cornerRadius = 6
                    btn.snp.makeConstraints { (make) in
                        make.left.equalTo(16*CGFloat(index + 1) + CGFloat(index)*width)
                        make.height.equalTo(40)
                        make.width.equalTo(width)
                        if self.message?.count ?? 0 > 0 {
                            make.top.equalTo(messageLabel.snp.bottom).offset(16)
                        } else if self.alertTitle?.count ?? 0 > 0 {
                            make.top.equalTo(titleLabel.snp.bottom).offset(16)
                        } else {
                            make.top.equalTo(16)
                        }
                        make.bottom.equalTo(-16)
                    }
                } else if self.style == .actionSheet {
                    var top = 16 + index * 50
                    if self.message?.count ?? 0 > 0 || self.alertTitle?.count ?? 0 > 0 {
                        top = 16 + index * 50
                    } else {
                        top = index * 50
                    }
                    if action.style == .cancel {
                        top += 7
                    }
                    btn.snp.makeConstraints { (make) in
                        make.left.equalTo(0)
                        make.right.equalTo(0)
                        make.height.equalTo(49)
                        if self.message?.count ?? 0 > 0 {
                            make.top.equalTo(messageLabel.snp.bottom).offset(top)
                        } else if self.alertTitle?.count ?? 0 > 0 {
                            make.top.equalTo(titleLabel.snp.bottom).offset(top)
                        } else {
                            make.top.equalTo(top)
                        }
                        if index == actions.count - 1 {
                            make.bottom.equalTo(-yt_kSafeBottomHeight-18)
                        }
                    }
                    if action.hasSelected {
                        let image = UIImageView.init(image: UIImage.init(named: "yt_selected"))
                        btn.addSubview(image)
                        image.snp.makeConstraints { (make) in
                            make.centerY.equalToSuperview()
                            make.right.equalTo(-16)
                        }
                    }
                    if index == actions.count - 1 {
                        let view = UIView()
                        view.backgroundColor = UIColor.white
                        baseView.addSubview(view)
                        view.snp.makeConstraints { (make) in
                            make.left.equalTo(0)
                            make.right.equalTo(0)
                            make.height.equalTo(yt_kSafeBottomHeight + 18)
                            make.bottom.equalTo(0)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.style == .actionSheet {
            let height = self.baseView.frame.size.height
            self.baseView.addRounded(corners: .allCorners, radius: 18)
            self.baseView.layer.masksToBounds = true
            UIView.animate(withDuration: animationDuration) {
                self.view.alpha = 1
                self.baseView.frame = CGRect.init(x: self.baseView.frame.origin.x, y: self.view.frame.height - height + 18, width: self.baseView.frame.width, height: height)
            }
        }
    }
    
    func addAction(_ action: YTAlertAction) {
        actions.append(action)
    }

    @objc func closeAction() {
        self.close()
    }
    
    func close(_ complection: YTEmptyBlock? = nil) {
        if self.style == .actionSheet {
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.alpha = 0
                self.baseView.frame = CGRect.init(x: self.baseView.frame.origin.x, y: self.view.frame.height, width: self.baseView.frame.width, height: self.baseView.frame.height)
            }) { (finish) in
                if finish {
                    if self.presentingViewController != nil {
                        self.dismiss(animated: false) {
                            UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                        }
                        complection?()
                    }
                }
            }
        } else {
            if self.presentingViewController != nil {
                self.dismiss(animated: false) {
                    UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
                complection?()
            }
        }
    }
    
    @objc func btnAction(_ sender: UIButton) {
        self.close { [weak self] in
            if let strongSelf = self {
                let index = sender.tag - 100
                if index < strongSelf.actions.count {
                    let action = strongSelf.actions[index]
                    action.handler?(action)
                }
            }
        }
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        var point = tap.location(in: self.view)
        point = self.view.convert(point, to: self.baseView)
        if !self.baseView.layer.contains(point) {
            self.close()
        }
    }
}

enum YTAlertActionStyle {
    case defaultStyle
    case cancel
}

class YTAlertAction: NSObject {
    
    var style: YTAlertActionStyle = .defaultStyle
    
    var title: String?
    
    var titleColor: UIColor = UIColor.white
    
    var backgroundColor: UIColor = UIColor.colorRGB(0xFF838F)
    
    var borderWidth: CGFloat = 0
    
    var borderColor: UIColor?
    
    var hasSelected: Bool = false
    
    var handler: ((YTAlertAction) -> Void)?
    
    init(title: String?, titleColor: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.colorRGB(0xFF838F), borderWidth: CGFloat = 0, borderColor: UIColor? = nil, style: YTAlertActionStyle = .defaultStyle, hasSelected: Bool = false, handler: ((YTAlertAction) -> Void)? = nil) {
        super.init()
        self.style = style
        self.title = title
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.handler = handler
        self.hasSelected = hasSelected
    }
}
