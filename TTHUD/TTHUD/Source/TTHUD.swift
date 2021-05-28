//
//  TTHUD.swift
//  TTHUD
//
//  Created by 张福润 on 2021/5/28.
//

import UIKit
import MBProgressHUD

// MARK: 常量
/// 优化最大的文字个数
fileprivate let SQUARE_ALLOW_TEXT_COUNT = 8

// MARK: 全局变量
let KEY_WINDOW = ((UIApplication.shared.delegate?.window)!)!

// MARK: - TTProgressHUD
class TTProgressHUD: MBProgressHUD {
    var type: TTProgressHUDType = .none
}

enum TTProgressHUDType {
    /// 无
    case none
    /// 只显示文字
    case onlyText
    /// 等待
    case loading
    /// 成功
    case success
    /// 错误
    case error
    /// 提示
    case info
    /// 进度
    case progress
}

// MARK: - TTHUD
class TTHUD {
    static let PlaceHolderImageSize = CGSize(width: 50, height: 55)
    static let PlaceHolderImage = UIImage.createImageFrom(color: .clear, size: PlaceHolderImageSize)
    static var mbpHUD: TTProgressHUD = TTProgressHUD()
    
    class func onlyText(_ text: String, _ view: UIView = KEY_WINDOW, isSquare: Bool = true) {
        self.hideWithType(.onlyText)
        
        guard let HUD = TTHUD.createHUD(view) else {
            return
        }
        HUD.mode = MBProgressHUDMode.text
        HUD.label.text = text
        HUD.contentColor = UIColor.white
        HUD.isSquare = text.TT_isSquare
        HUD.hide(animated: true, afterDelay: 1)
        HUD.type = .onlyText
        self.updateHUDView(HUD)
    }
    
    class func show(_ text: String = "", _ view: UIView = KEY_WINDOW) {
        self.drawRoundLoadingView(text, view: view)
    }
    
    class func hide() {
        self.hideWithType(.none)
    }
    
    fileprivate class func hideWithType(_ type: TTProgressHUDType) {
        mbpHUD.hide(animated: true)
        mbpHUD.type = type
    }
    
    class func success(_ text: String = "成功", _ view: UIView = KEY_WINDOW) {
        self.drawSuccessView(text, view: view)
    }
    
    class func error(_ text: String = "失败了", _ view: UIView = KEY_WINDOW) {
        self.drawErrorView(text, view: view)
    }
    
    class func progress(_ text: String = "加载中", _ view: UIView = KEY_WINDOW) {
        if mbpHUD.type != .progress {
            self.drawProgressLoadingView(text, view: view)
        }
        
        mbpHUD.label.text = text
    }
    
    class func info(_ text: String = "加载中", _ view: UIView = KEY_WINDOW) {
        self.drawInfoView(text, view: view)
    }
}

extension TTHUD {
    fileprivate class func updateHUDView(_ HUDView: TTProgressHUD) {
        mbpHUD.hide(animated: true)
        mbpHUD = HUDView
    }
    class func createHUD(_ view: UIView?, size: CGSize = .zero) -> TTProgressHUD? {
        var view = view
        let window = KEY_WINDOW
        
        if view == nil {
            view = window
        }
        
        let HUD = TTProgressHUD.init(view: view ?? UIView())
        if size != .zero {
            HUD.frame.size = size
        }
        HUD.bezelView.style = .blur
        HUD.bezelView.blurEffectStyle = .dark
        
        HUD.label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        view?.addSubview(HUD)
        HUD.show(animated: true)
        
        HUD.animationType = MBProgressHUDAnimation.zoom
        HUD.removeFromSuperViewOnHide = true
        return HUD
        
    }
    
    class func HUDAnimationView(view: UIView,
                                isSquare: Bool = true,
                                type: TTProgressHUDType = .none
    ) -> TTProgressHUD? {
        guard let HUD = TTHUD.createHUD(view) else {
            return nil
        }
        HUD.mode = MBProgressHUDMode.customView
        HUD.contentColor = UIColor.white
        HUD.isSquare = isSquare
        HUD.type = type
        
        let iconImageView = UIImageView(frame: CGRect(origin: .zero, size: PlaceHolderImageSize))
        let image = PlaceHolderImage
        iconImageView.contentMode = .scaleToFill
        iconImageView.image = image
        
        let layerBlock = { () -> CAShapeLayer? in
            switch type {
            case .none, .onlyText:
                return nil
            case .success:
                return self.successLayer(frame: iconImageView.bounds)
            case .error:
                return self.errorLayer(frame: iconImageView.bounds)
            case .info:
                return self.infoLayer(frame: iconImageView.bounds)
            case .loading, .progress:
                return self.loadingLayer(frame: iconImageView.bounds)
            }
        }
        if let layer = layerBlock() {
            iconImageView.layer.addSublayer(layer)
        }
        
        HUD.customView = iconImageView
        
        return HUD
    }
}


// MARK: - Loading
extension TTHUD {
    class func drawRoundLoadingView(_ text: String, view: UIView) {
        let type: TTProgressHUDType = .loading
        self.hideWithType(type)
        
        guard let HUD = HUDAnimationView(view: view,
                                         isSquare: text.TT_isSquare,
                                         type: type) else {
            return
        }
        HUD.label.text = text
        
        self.updateHUDView(HUD)
    }
    
    class func loadingLayer(frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 55)) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.frame = frame
        layer.strokeColor = UIColor.white.cgColor
        
        let STROKE_WIDTH = CGFloat(3)
        // 绘制外部透明的圆形
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: layer.frame.size.width / 2 - STROKE_WIDTH, startAngle: 0 * .pi / 180, endAngle: 360 * .pi / 180, clockwise: false)
        // 创建外部透明圆形的图层
        let alphaLineLayer = CAShapeLayer()
        alphaLineLayer.path = circlePath.cgPath // 设置透明圆形的绘图路径
        if let strokeColor = layer.strokeColor {
            alphaLineLayer.strokeColor = UIColor(cgColor: strokeColor).withAlphaComponent(0.1).cgColor
        } // 设置图层的透明圆形的颜色
        alphaLineLayer.lineWidth = STROKE_WIDTH // 设置圆形的线宽
        alphaLineLayer.fillColor = UIColor.clear.cgColor // 填充颜色透明
        
        layer.addSublayer(alphaLineLayer) // 把外部半透明圆形的图层加到当前图层上
        
        let drawLayer = CAShapeLayer()
        let progressPath = UIBezierPath()
        progressPath.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: layer.frame.size.width / 2 - STROKE_WIDTH, startAngle: 0 * .pi / 180, endAngle: 360 * .pi / 180, clockwise: true)
        
        drawLayer.lineWidth = STROKE_WIDTH
        drawLayer.fillColor = UIColor.clear.cgColor
        drawLayer.path = progressPath.cgPath
        drawLayer.frame = drawLayer.bounds
        drawLayer.strokeColor = layer.strokeColor
        layer.addSublayer(drawLayer)
        
        let progressRotateTimingFunction = CAMediaTimingFunction(controlPoints: 0.25, _: 0.80, _: 0.75, _: 1.00)
        
        // 开始划线的动画
        let progressLongAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressLongAnimation.fromValue = NSNumber(value: 0.0)
        progressLongAnimation.toValue = NSNumber(value: 1.0)
        progressLongAnimation.duration = 2
        progressLongAnimation.timingFunction = progressRotateTimingFunction
        progressLongAnimation.repeatCount = 10000
        // 线条逐渐变短收缩的动画
        let progressLongEndAnimation = CABasicAnimation(keyPath: "strokeStart")
        progressLongEndAnimation.fromValue = NSNumber(value: 0.0)
        progressLongEndAnimation.toValue = NSNumber(value: 1.0)
        progressLongEndAnimation.duration = 2
        let strokeStartTimingFunction = CAMediaTimingFunction(controlPoints: 0.65, _: 0.0, _: 1.0, _: 1.0)
        progressLongEndAnimation.timingFunction = strokeStartTimingFunction
        progressLongEndAnimation.repeatCount = 10000
        let progressRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        progressRotateAnimation.fromValue = NSNumber(value: 0.0)
        progressRotateAnimation.toValue = NSNumber(value: .pi / 180.0 * 360)
        progressRotateAnimation.repeatCount = 1000000
        progressRotateAnimation.duration = 6
        drawLayer.add(progressLongAnimation, forKey: "strokeEnd")
        layer.add(progressRotateAnimation, forKey: "transfrom.rotation.z")
        drawLayer.add(progressLongEndAnimation, forKey: "strokeStart")
        
        return layer
    }
}

// MARK: - Success
extension TTHUD {
    class func drawSuccessView(_ text: String, view: UIView) {
        let type: TTProgressHUDType = .success
        self.hideWithType(type)
        
        
        guard let HUD = HUDAnimationView(view: view,
                                         isSquare: text.TT_isSquare,
                                         type: type) else {
            return
        }
        HUD.label.text = text
        HUD.hide(animated:true, afterDelay: 1.0)
        
        self.updateHUDView(HUD)
    }
    
    class func successLayer(frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 55)) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.frame = frame
        
        layer.strokeColor = UIColor.white.cgColor
        
        let STROKE_WIDTH = CGFloat(3) // 默认的划线线条宽度
        
        // 绘制外部透明的圆形
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: CGFloat(layer.frame.size.width * 0.5 - STROKE_WIDTH), startAngle: 0 * .pi / 180, endAngle: 360 * .pi / 180, clockwise: false)
        // 创建外部透明圆形的图层
        let alphaLineLayer = CAShapeLayer()
        alphaLineLayer.path = circlePath.cgPath // 设置透明圆形的绘图路径
        if let strokeColor = layer.strokeColor {
            alphaLineLayer.strokeColor = UIColor(cgColor: strokeColor).withAlphaComponent(0.1).cgColor
        } // 设置图层的透明圆形的颜色
        alphaLineLayer.lineWidth = CGFloat(STROKE_WIDTH) // 设置圆形的线宽
        alphaLineLayer.fillColor = UIColor.clear.cgColor // 填充颜色透明
        
        layer.addSublayer(alphaLineLayer) // 把外部半透明圆形的图层加到当前图层上
        //  Converted to Swift 5.4 by Swiftify v5.4.24202 - https://swiftify.com/
        // 设置当前图层的绘制属性
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round // 圆角画笔
        layer.lineWidth = CGFloat(STROKE_WIDTH)
        
        // 半圆+动画的绘制路径初始化
        let path = UIBezierPath()
        // 绘制大半圆
        path.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: layer.frame.size.width / 2 - CGFloat(STROKE_WIDTH), startAngle: 67 * .pi / 180, endAngle: -158 * .pi / 180, clockwise: false)
        // 绘制对号第一笔
        path.addLine(to: CGPoint(x: layer.frame.size.width * 0.42, y: layer.frame.size.width * 0.68))
        // 绘制对号第二笔
        path.addLine(to: CGPoint(x: layer.frame.size.width * 0.75, y: layer.frame.size.width * 0.35))
        // 把路径设置为当前图层的路径
        layer.path = path.cgPath
        
        let timing = CAMediaTimingFunction(controlPoints: 0.3, _: 0.6, _: 0.8, _: 1.1)
        // 创建路径顺序绘制的动画
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5 // 动画使用时间
        animation.fromValue = NSNumber(value: Int32(0.0)) // 从头
        animation.toValue = NSNumber(value: Int32(1.0)) // 画到尾
        // 创建路径顺序从结尾开始消失的动画
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = 0.4 // 动画使用时间
        strokeStartAnimation.beginTime = CACurrentMediaTime() + 0.2 // 延迟0.2秒执行动画
        strokeStartAnimation.fromValue = NSNumber(value: 0.0) // 从开始消失
        strokeStartAnimation.toValue = NSNumber(value: 0.74) // 一直消失到整个绘制路径的74%，这个数没有啥技巧，一点点调试看效果，希望看此代码的人不要被这个数值怎么来的困惑
        strokeStartAnimation.timingFunction = timing
        layer.strokeStart = 0.74 // 设置最终效果，防止动画结束之后效果改变
        layer.strokeEnd = 1.0
        
        layer.add(animation, forKey: "strokeEnd") // 添加俩动画
        layer.add(strokeStartAnimation, forKey: "strokeStart")
        
        
        return layer
    }
}
// MARK: - Error
extension TTHUD {
    class func drawErrorView(_ text: String, view: UIView) {
        let type: TTProgressHUDType = .error
        self.hideWithType(type)
        
        guard let HUD = HUDAnimationView(view: view,
                                         isSquare: text.TT_isSquare,
                                         type: type) else {
            return
        }
        HUD.label.text = text
        HUD.label.numberOfLines = 2
        HUD.hide(animated:true, afterDelay: 1.0)
        
        self.updateHUDView(HUD)
    }
    
    class func errorLayer(frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 55)) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.frame = frame
        
        layer.strokeColor = UIColor.white.cgColor
        let STROKE_WIDTH = CGFloat(3) // 默认的划线线条宽度
        // 绘制外部透明的圆形
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: CGFloat(layer.frame.size.width / 2 - STROKE_WIDTH), startAngle: 0 * .pi / 180, endAngle: 360 * .pi / 180, clockwise: false)
        // 创建外部透明圆形的图层
        let alphaLineLayer = CAShapeLayer()
        alphaLineLayer.path = circlePath.cgPath // 设置透明圆形的绘图路径
        if let strokeColor = layer.strokeColor {
            alphaLineLayer.strokeColor = UIColor(cgColor: strokeColor).withAlphaComponent(0.1).cgColor
        }
        // ↑ 设置图层的透明圆形的颜色，取图标颜色之后设置其对应的0.1透明度的颜色
        alphaLineLayer.lineWidth = STROKE_WIDTH // 设置圆形的线宽
        alphaLineLayer.fillColor = UIColor.clear.cgColor // 填充颜色透明
        
        layer.addSublayer(alphaLineLayer) // 把外部半透明圆形的图层加到当前图层上
        
        // 开始画叉的两条线，首先画逆时针旋转的线
        let leftLayer = CAShapeLayer()
        // 设置当前图层的绘制属性
        leftLayer.frame = layer.bounds
        leftLayer.fillColor = UIColor.clear.cgColor
        leftLayer.lineCap = .round // 圆角画笔
        leftLayer.lineWidth = STROKE_WIDTH
        leftLayer.strokeColor = layer.strokeColor
        
        // 半圆+动画的绘制路径初始化
        let leftPath = UIBezierPath()
        // 绘制大半圆
        leftPath.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: layer.frame.size.width / 2 - STROKE_WIDTH, startAngle: -43 * .pi / 180, endAngle: -315 * .pi / 180, clockwise: false)
        leftPath.addLine(to: CGPoint(x: layer.frame.size.width * 0.35, y: layer.frame.size.width * 0.35))
        
        leftLayer.path = leftPath.cgPath
        
        layer.addSublayer(leftLayer)
        
        // 逆时针旋转的线
        let rightLayer = CAShapeLayer()
        // 设置当前图层的绘制属性
        rightLayer.frame = layer.bounds
        rightLayer.fillColor = UIColor.clear.cgColor
        rightLayer.lineCap = .round // 圆角画笔
        rightLayer.lineWidth = STROKE_WIDTH
        rightLayer.strokeColor = layer.strokeColor
        let rightPath = UIBezierPath()
        // 绘制大半圆
        rightPath.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: layer.frame.size.width / 2 - STROKE_WIDTH, startAngle: -128 * .pi / 180, endAngle: 133 * .pi / 180, clockwise: true)
        rightPath.addLine(to: CGPoint(x: layer.frame.size.width * 0.65, y: layer.frame.size.width * 0.35))
        
        // 把路径设置为当前图层的路径
        rightLayer.path = rightPath.cgPath
        
        layer.addSublayer(rightLayer)
        
        
        let timing = CAMediaTimingFunction(controlPoints: 0.3, _: 0.6, _: 0.8, _: 1.1)
        // 创建路径顺序绘制的动画
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5 // 动画使用时间
        animation.fromValue = NSNumber(value: Int32(0.0)) // 从头
        animation.toValue = NSNumber(value: Int32(1.0)) // 画到尾
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = 0.4 // 动画使用时间
        strokeStartAnimation.beginTime = CACurrentMediaTime() + 0.2 // 延迟0.2秒执行动画
        strokeStartAnimation.fromValue = NSNumber(value: 0.0) // 从开始消失
        strokeStartAnimation.toValue = NSNumber(value: 0.84) // 一直消失到整个绘制路径的84%，这个数没有啥技巧，一点点调试看效果，希望看此代码的人不要被这个数值怎么来的困惑
        strokeStartAnimation.timingFunction = timing
        
        leftLayer.strokeStart = 0.84 // 设置最终效果，防止动画结束之后效果改变
        leftLayer.strokeEnd = 1.0
        rightLayer.strokeStart = 0.84 // 设置最终效果，防止动画结束之后效果改变
        rightLayer.strokeEnd = 1.0
        
        
        leftLayer.add(animation, forKey: "strokeEnd") // 添加俩动画
        leftLayer.add(strokeStartAnimation, forKey: "strokeStart")
        rightLayer.add(animation, forKey: "strokeEnd") // 添加俩动画
        rightLayer.add(strokeStartAnimation, forKey: "strokeStart")
        
        return layer
    }
}

// MARK: - Info
extension TTHUD {
    class func drawInfoView(_ text: String, view: UIView) {
        let type: TTProgressHUDType = .info
        self.hideWithType(type)
        
        
        guard let HUD = HUDAnimationView(view: view,
                                         isSquare: text.TT_isSquare,
                                         type: type) else {
            return
        }
        HUD.label.text = text
        
        HUD.hide(animated:true, afterDelay: 1.0)
        self.updateHUDView(HUD)
    }
    
    class func infoLayer(frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 55)) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.frame = frame
        
        layer.strokeColor = UIColor.white.cgColor
        
        let STROKE_WIDTH = CGFloat(3) // 默认的划线线条宽度
        
        // 绘制外部透明的圆形
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2), radius: CGFloat(layer.frame.size.width * 0.5 - STROKE_WIDTH), startAngle: 0 * .pi / 180, endAngle: 360 * .pi / 180, clockwise: false)
        // 创建外部透明圆形的图层
        let alphaLineLayer = CAShapeLayer()
        alphaLineLayer.path = circlePath.cgPath // 设置透明圆形的绘图路径
        if let strokeColor = layer.strokeColor {
            alphaLineLayer.strokeColor = UIColor(cgColor: strokeColor).withAlphaComponent(0.1).cgColor
        } // 设置图层的透明圆形的颜色
        alphaLineLayer.lineWidth = CGFloat(STROKE_WIDTH) // 设置圆形的线宽
        alphaLineLayer.fillColor = UIColor.clear.cgColor // 填充颜色透明
        
        layer.addSublayer(alphaLineLayer) // 把外部半透明圆形的图层加到当前图层上
        //  Converted to Swift 5.4 by Swiftify v5.4.24202 - https://swiftify.com/
        // 设置当前图层的绘制属性
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round // 圆角画笔
        layer.lineWidth = CGFloat(STROKE_WIDTH)
        
        // 半圆+动画的绘制路径初始化
        let path = UIBezierPath()
        
        let imageWH = layer.frame.size.width
        path.addArc(withCenter: CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height / 2),
                    radius: layer.frame.size.width / 2 - CGFloat(STROKE_WIDTH), startAngle: -90 * .pi / 180,
                    endAngle: 271 * .pi / 180,
                    clockwise: false)
        path.addLine(to: CGPoint(x: imageWH / 2, y: imageWH / 3 + 2))
        
        path.move(to: CGPoint(x: imageWH / 2, y: imageWH / 2))
        path.addLine(to: CGPoint(x: imageWH / 2, y: imageWH * 3 / 4))
        
//        layer.frame.size.width * 0.75, y: layer.frame.size.width * 0.35))
        // 把路径设置为当前图层的路径
        layer.path = path.cgPath
        
        let endValue = CGFloat(0.91)
        
        let timing = CAMediaTimingFunction(controlPoints: 0.3, _: 0.6, _: 0.8, _: 1.1)
        // 创建路径顺序绘制的动画
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5 // 动画使用时间
        animation.fromValue = NSNumber(value: Int32(0.0)) // 从头
        animation.toValue = NSNumber(value: Int32(1.0)) // 画到尾
        // 创建路径顺序从结尾开始消失的动画
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = 0.4 // 动画使用时间
        strokeStartAnimation.beginTime = CACurrentMediaTime() + 0.2 // 延迟0.2秒执行动画
        strokeStartAnimation.fromValue = NSNumber(value: 0.0) // 从开始消失
        strokeStartAnimation.toValue = NSNumber(value: Double(endValue)) // 一直消失到整个绘制路径的74%，这个数没有啥技巧，一点点调试看效果，希望看此代码的人不要被这个数值怎么来的困惑
        strokeStartAnimation.timingFunction = timing
        layer.strokeStart = endValue // 设置最终效果，防止动画结束之后效果改变
        layer.strokeEnd = 1.0
        
        layer.add(animation, forKey: "strokeEnd") // 添加俩动画
        layer.add(strokeStartAnimation, forKey: "strokeStart")
        
        return layer
    }
}

// MARK: - Progress
extension TTHUD {
    class func drawProgressLoadingView(_ text: String, view: UIView) {
        let type: TTProgressHUDType = .progress
        self.hideWithType(type)
        
        
        guard let HUD = HUDAnimationView(view: view,
                                         isSquare: text.TT_isSquare,
                                         type: type) else {
            return
        }
        
        HUD.label.text = text
        self.updateHUDView(HUD)
    }
}


// MARK: - extension
fileprivate extension String {
    var TT_isSquare: Bool {
        get {
            return self.count < SQUARE_ALLOW_TEXT_COUNT
        }
    }
}

fileprivate extension UIImage {
    class func createImageFrom(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? nil
    }
    
}
