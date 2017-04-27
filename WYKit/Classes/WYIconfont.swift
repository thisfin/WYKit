//
//  WYIconfont.swift
//  SwiftQRCodeScan
//
//  Created by wenyou on 2016/11/8.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation
import CoreText

#if os(iOS)
    import UIKit
    public typealias WYFont = UIFont
    public typealias WYImage = UIImage
#else
    import AppKit
    public typealias WYFont = NSFont
    public typealias WYImage = NSImage
#endif


public class WYIconfont: NSObject {
    private static var fontName = "FontAwesome"
    private static var fontPath = "fontawesome-webfont_4.6.3"

    // once范例
    private static var oneTimeThing: () = {
        let frameworkBundle: Bundle = Bundle(for: WYIconfont.classForCoder())
        let path: String? = frameworkBundle.path(forResource: WYIconfont.fontPath, ofType: "ttf")
        if let dynamicFontData = NSData(contentsOfFile: path!) {
            let dataProvider: CGDataProvider? = CGDataProvider(data: dynamicFontData)
            let font: CGFont? = CGFont(dataProvider!)
            var error: Unmanaged<CFError>? = nil

            if !CTFontManagerRegisterGraphicsFont(font!, &error) {
                let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
                NSLog("Failed to load font: %@", errorDescription as String)
            }
            error?.release()
        }
    }()

    // MARK: - public
    public static func setFont(fontPath: String, fontName: String) {
        WYIconfont.fontPath = fontPath
        WYIconfont.fontName = fontName
    }

    public static func fontOfSize(_ fontSize: CGFloat) -> WYFont {
        _ = oneTimeThing

        let font: WYFont? = WYFont(name: WYIconfont.fontName, size: fontSize)
        assert(font != nil, WYIconfont.fontName + " couldn't be loaded")
        return font!
    }

    public static func imageWithIcon(content: String, backgroundColor: WYColor = WYColor.clear, iconColor: WYColor = WYColor.white, size: CGSize) -> WYImage {
        // 逐步缩小算字号
        var fontSize: Int!
        let constraintSize = CGSize(width: size.width, height: CGFloat(MAXFLOAT))
        for i in stride(from: 500, to: 5, by: -2) {
            let rect = content.boundingRect(with: constraintSize,
                                            options: NSStringDrawingOptions.usesFontLeading,
                                            attributes: [NSFontAttributeName: WYIconfont.fontOfSize(CGFloat(i))],
                                            context: nil)
            fontSize = i
            if rect.size.height <= size.height {
                break
            }
        }

        #if os(iOS)
            // 绘制
            let textRext = CGRect(origin: CGPoint.zero, size: size)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            backgroundColor.setFill()
            UIBezierPath(rect: textRext).fill()
            content.draw(in:textRext, withAttributes: [NSFontAttributeName: WYIconfont.fontOfSize(CGFloat(fontSize)),
                                                       NSForegroundColorAttributeName: iconColor,
                                                       NSBackgroundColorAttributeName: backgroundColor,
                                                       NSParagraphStyleAttributeName: {
                                                        let style = NSMutableParagraphStyle()
                                                        style.alignment = NSTextAlignment.center
                                                        return style}()])
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        #else
            // 绘制
            let textRext = NSRect(origin: NSPoint.zero, size: size)
            let image = NSImage(size: size)
            image.lockFocus()
            //        let context : CGContext = (NSGraphicsContext.current()?.cgContext)!
            //        context.beginPath()
            backgroundColor.setFill()
            NSBezierPath(rect: textRext).fill()
            content.draw(in:textRext, withAttributes: [NSFontAttributeName: WYIconfont.fontOfSize(CGFloat(fontSize)),
                                                       NSForegroundColorAttributeName: iconColor,
                                                       NSBackgroundColorAttributeName: backgroundColor,
                                                       NSParagraphStyleAttributeName: {
                                                        let style = NSMutableParagraphStyle()
                                                        style.alignment = NSTextAlignment.center
                                                        return style}()])
            image.unlockFocus()
            return image
        #endif
    }

    public static func imageWithIcon(content: String, backgroundColor: WYColor = WYColor.clear, iconColor: WYColor = WYColor.white, fontSize: CGFloat) -> WYImage {
        let attributes = [NSFontAttributeName: WYIconfont.fontOfSize(fontSize),
                          NSForegroundColorAttributeName: iconColor,
                          NSBackgroundColorAttributeName: backgroundColor,
                          NSParagraphStyleAttributeName: {
                            let style = NSMutableParagraphStyle()
                            style.alignment = NSTextAlignment.center
                            return style}()]
        #if os(iOS)
            var size = content.size(attributes: attributes)
            size = CGSize(width: size.width * 1.1, height: size.height * 1.05)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            backgroundColor.setFill()
            UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size)).fill()
            content.draw(at: CGPoint(x: size.width * 0.05, y: size.height * 0.025), withAttributes: attributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        #else
            var size = content.size(withAttributes: attributes)
            size = NSMakeSize(size.width * 1.1, size.height * 1.05)
            let image = NSImage(size: size)
            image.lockFocus()
            backgroundColor.setFill()
            NSBezierPath(rect: NSRect(origin: NSPoint.zero, size: size)).fill()
            content.draw(at: NSMakePoint(size.width * 0.05, size.height * 0.025), withAttributes: attributes)
            image.unlockFocus()
            return image
        #endif
    }
}
