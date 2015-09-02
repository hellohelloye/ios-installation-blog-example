//
//  UIButtonExtensions.swift
//  Example
//
//    The MIT License (MIT)
//
//    Copyright (c) 2015 Testlio, Inc.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//
//  Created by Henri Normak on 26/08/15.
//  Copyright (c) 2015 Testlio. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setOutlinedBackground(lineWidth: CGFloat, cornerOffset: UIOffset) {
        // Create an image to apply as the background
        let size = CGSize(width: lineWidth * 2 + cornerOffset.horizontal * 2 + 2.0, height: lineWidth * 2 + cornerOffset.vertical * 2 + 2.0)
        
        let pathSize = CGSize(width: size.width - lineWidth, height: size.height - lineWidth)
        let pathOrigin = CGPoint(x: lineWidth / 2.0, y: lineWidth / 2.0)
        let path = CGPathCreateWithRoundedRect(CGRect(origin: pathOrigin, size: pathSize),
            cornerOffset.horizontal, cornerOffset.vertical, nil)
        let capInsets = UIEdgeInsets(top: cornerOffset.vertical + lineWidth, left: cornerOffset.horizontal + lineWidth, bottom: cornerOffset.vertical + lineWidth, right: cornerOffset.horizontal + lineWidth)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextAddPath(ctx, path)
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextStrokePath(ctx)
        
        let normalImage = UIGraphicsGetImageFromCurrentImageContext().resizableImageWithCapInsets(capInsets).imageWithRenderingMode(.AlwaysTemplate)
        
        CGContextClearRect(ctx, CGRect(origin: CGPointZero, size: size))
        
        CGContextAddPath(ctx, path)
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextSetStrokeColorWithColor(ctx, UIColor.lightGrayColor().CGColor)
        CGContextStrokePath(ctx)
        
        let disabledImage = UIGraphicsGetImageFromCurrentImageContext().resizableImageWithCapInsets(capInsets).imageWithRenderingMode(.AlwaysOriginal)
        
        UIGraphicsEndImageContext()
        
        var contentInsets = capInsets
        contentInsets.top += lineWidth
        contentInsets.bottom += lineWidth
        contentInsets.left += cornerOffset.horizontal
        contentInsets.right += cornerOffset.horizontal
        
        self.contentEdgeInsets = contentInsets
        self.setBackgroundImage(disabledImage, forState: .Disabled)
        self.setBackgroundImage(normalImage, forState: .Normal)
    }
}
