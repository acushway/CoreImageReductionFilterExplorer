//
//  ImageView.swift
//  CoreImageHelpers
//
//  Created by Simon Gladman on 09/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import GLKit
import UIKit

/// `ImageView` wraps up a `GLKView` and its delegate into a single class to simplify the
/// display of `CIImage`.
///
/// `ImageView` is hardcoded to simulate ScaleAspectFit: images are sized to retain their
/// aspect ratio and fit within the available bounds.
///
/// `ImageView` also respects `backgroundColor` for opaque colors

class ImageView: GLKView
{
    let eaglContext = EAGLContext(api: .openGLES2)
    
    lazy var ciContext: CIContext =
    {
        [unowned self] in
        
        return CIContext(eaglContext: self.eaglContext!,
            options: [kCIContextWorkingColorSpace: NSNull()])
        }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame, context: eaglContext!)
        
        context = self.eaglContext!
        delegate = self
    }
    
    override init(frame: CGRect, context: EAGLContext)
    {
        fatalError("init(frame:, context:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The image to display
    var image: CIImage?
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
}

extension ImageView: GLKViewDelegate
{
    func glkView(_ view: GLKView, drawIn rect: CGRect)
    {
        guard let image = image else
        {
            return
        }
        
        let targetRect = image.extent.aspectFitInRect(
            target: CGRect(origin: CGPoint.zero,
                size: CGSize(width: drawableWidth,
                    height: drawableHeight)))
        
        let ciBackgroundColor = CIColor(color: backgroundColor ?? UIColor.white)
        
        ciContext.draw(CIImage(color: ciBackgroundColor),
                       in: CGRect(x: 0,
                                  y: 0,
                                  width: drawableWidth,
                                  height: drawableHeight),
                       from: CGRect(x: 0,
                y: 0,
                width: drawableWidth,
                height: drawableHeight))
        
        ciContext.draw(image,
                       in: targetRect,
                       from: image.extent)
    }
}

extension CGRect
{
    func aspectFitInRect(target: CGRect) -> CGRect
    {
        let scale: CGFloat =
        {
            let scale = target.width / self.width
            
            return self.height * scale <= target.height ?
                scale :
                target.height / self.height
        }()
        
        let width = self.width * scale
        let height = self.height * scale
        let x = target.midX - width / 2
        let y = target.midY - height / 2
        
        return CGRect(x: x,
            y: y,
            width: width,
            height: height)
    }
}
