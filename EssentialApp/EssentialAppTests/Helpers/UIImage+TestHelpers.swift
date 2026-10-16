//
//  UIImage+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

    /// The image's pixels as 8-bit sRGB RGBA, so tests compare what an image shows
    /// rather than how it was encoded (PNG metadata changes between iOS versions).
    var pixels: [UInt8]? {
        guard let cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let didDraw = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }

            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }

        return didDraw ? pixels : nil
    }
}

extension Data {
    /// The pixels of the image this data encodes, for comparing against a rendered image.
    var imagePixels: [UInt8] {
        UIImage(data: self)!.pixels!
    }
}
