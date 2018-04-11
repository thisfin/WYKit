//
//  UIColorEx.swift
//  SwiftQRCodeScan
//
//  Created by wenyou on 2016/11/8.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#if os(iOS)
    import UIKit
    public typealias WYColor = UIColor
#else
    import AppKit
    public typealias WYColor = NSColor
#endif

extension WYColor {
    public static func colorWithHexValue(_ hexValue: UInt, alpha: UInt = 255) -> WYColor {
        let r: CGFloat = CGFloat((hexValue & 0x00FF0000) >> 16) / 255
        let g: CGFloat = CGFloat((hexValue & 0x0000FF00) >> 8) / 255
        let b: CGFloat = CGFloat(hexValue & 0x000000FF) / 255
        let a: CGFloat = CGFloat(alpha) / 255
        return self.init(red: r, green: g, blue: b, alpha: a)
    }

    // param string "aarrggbb" or "#aarrggbb" or "rrggbb" or "#rrggbb" or "rgb" or "#rgb"
    public static func colorWithString(_ string: String) -> WYColor {
        let string = string.lowercased()
        let len = string.count
        if len == 3 || (len == 4 && string.hasPrefix("#")) || (len == 5 && string.hasPrefix("0x")) || len == 6 || (len == 7 && string.hasPrefix("#")) || (len == 8 && string.hasPrefix("0x")) {
            if let hexValue = hexValueOfString(string) {
                return colorWithHexValue(hexValue)
            }
        } else if len == 8 || (len == 9 && string.hasPrefix("#")) || (len == 10 && string.hasPrefix("0x")) {
            if var hexValue = hexValueOfString(string) {
                let alpha = hexValue & 0xFF
                hexValue = hexValue >> 8
                return colorWithHexValue(hexValue, alpha: alpha)
            }
        }
        return .clear
    }

    private static func hexValueOfString(_ string: String) -> UInt? {
        var string: String = string

        if string.hasPrefix("#") {
            string = String(string.suffix(from: string.index(string.startIndex, offsetBy: 1)))
        } else if string.hasPrefix("0x") {
            string = String(string.suffix(from: string.index(string.startIndex, offsetBy: 2)))
        }

        if string.count == 3 {
            var s = ""
            string.forEach({ (c) in
                s.append(c)
                s.append(c)
            })
            string = s
        }
        // string = string.characters.reduce("", {$0 + String($1) + String($1)})

        var i32: UInt32 = 0
        guard Scanner(string: string).scanHexInt32(&i32) else {
            return nil
        }
        return UInt(i32)
    }

    public func toHexString(prefix: ColorStringPrefix = ColorStringPrefix.hex, includeAlpha: Bool = true) -> String {
        #if os(iOS)
            if let components = cgColor.components { // ios 同样会有下面 colorspace 转换的问题, 遇到了再改
                return toStringWith(r: Int(components[0] * 255), g: Int(components[1] * 255), b: Int(components[2] * 255), alpha: Int(components[3] * 255), prefix: prefix, includeAlpha: includeAlpha)
            }
        #else
            switch self.colorSpaceName {
            case NSCalibratedRGBColorSpace:
                return toStringWith(r: Int(redComponent * 255), g: Int(greenComponent * 255), b: Int(blueComponent * 255), alpha: Int(alphaComponent * 255), prefix: prefix, includeAlpha: includeAlpha)
            case NSCalibratedWhiteColorSpace:
                return toStringWith(r: Int(whiteComponent * 255), g: Int(whiteComponent * 255), b: Int(whiteComponent * 255), alpha: Int(alphaComponent * 255), prefix: prefix, includeAlpha: includeAlpha)
            default:
                if let color = self.usingColorSpaceName(NSCalibratedRGBColorSpace) {
                    return toStringWith(r: Int(color.redComponent * 255), g: Int(color.greenComponent * 255), b: Int(color.blueComponent * 255), alpha: Int(color.alphaComponent * 255), prefix: prefix, includeAlpha: includeAlpha)
                }
            }
        #endif
        return ""
    }

    private func toStringWith(r: Int, g: Int, b: Int, alpha: Int, prefix: ColorStringPrefix = ColorStringPrefix.hex, includeAlpha: Bool = true) -> String {
        var string = ""
        switch prefix {
        case .hex:
            string.append("0x")
        case .number:
            string.append("#")
        default:
            ()
        }
        string.append("%02X%02X%02X" + (includeAlpha ? "%02X" : ""))
        return String(format: string, r, g, b, alpha)
    }
}

public enum ColorStringPrefix {
    case null, number, hex
}
