//
//  Elissa.swift
//  Kitchen Stories
//
//  Created by Kersten Broich on 05/04/16.
//  Copyright © 2016 Kitchen Stories. All rights reserved.
//

import Foundation

public struct ElissaConfiguration {
    public var message: String?
    public var image: UIImage?
    public var backgroundColor: UIColor?
    public var textColor: UIColor?
    public var font: UIFont?
    
    public init() {}
}

public class Elissa: UIView {

    public static var isVisible: Bool {
        return staticElissa != nil
    }
    
    private static var staticElissa: Elissa?

    public static func dismiss() {
        if staticElissa != nil {
            staticElissa!.removeFromSuperview()
            staticElissa = nil
        }
    }
    
    static func showElissa(sourceView: UIView, configuration: ElissaConfiguration, handler: CompletionHandlerClosure) -> UIView? {
        staticElissa = Elissa(view: sourceView, configuration: configuration)
        staticElissa?.handler = handler
        return staticElissa
    }
    
    private var handler: CompletionHandlerClosure!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
 
    @IBAction func actionButtonTapped(sender: UIButton) {
        handler()
    }
    
    private let arrowSize: CGSize = CGSize(width: 20, height: 10)
    private let popupHeight: CGFloat = 36.0
    private let offsetToSourceView: CGFloat = 5.0
    private var popupMinMarginScreenBounds: CGFloat = 5.0
    
    private init(view: UIView, configuration: ElissaConfiguration) {
        super.init(frame: CGRect.zero)
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let views = bundle.loadNibNamed("Elissa", owner: self, options: nil)
        
        guard let embeddedContentView = views.first as? UIView else { return }
        addSubview(embeddedContentView)
        
        embeddedContentView.backgroundColor = configuration.backgroundColor
        
        messageLabel.text = configuration.message
        messageLabel.font = configuration.font
        messageLabel.textColor = configuration.textColor
        
        iconImageView.image = configuration.image
        iconImageView.tintColor = configuration.textColor
        
        calculatePositon(sourceView: view, contentView: self, backgroundColor: configuration.backgroundColor ?? self.tintColor)
        embeddedContentView.layer.cornerRadius = 3.0
        
        embeddedContentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        bringSubviewToFront(embeddedContentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func calculatePositon(sourceView sourceView: UIView, contentView: UIView, backgroundColor: UIColor) -> UIView {
        var updatedFrame = CGRect()
        updatedFrame.size.width = contentView.frame.size.width + 45 // TODO: get values from autolayout constraints
        updatedFrame.size.height = popupHeight
        updatedFrame.origin.x = sourceView.center.x - updatedFrame.size.width / 2
        updatedFrame.origin.y = (sourceView.frame.origin.y - sourceView.frame.size.height) + offsetToSourceView
        
        contentView.frame = updatedFrame
        contentView.layer.cornerRadius = 5
        
        let checkPoint = contentView.frame.origin.x + contentView.frame.size.width
        let appWidth = UIScreen.mainScreen().applicationFrame.size.width
        
        var offset: CGFloat = 0.0
        
        if checkPoint > appWidth {
            offset = checkPoint - appWidth
        } else if contentView.frame.origin.x < 5 {
            popupMinMarginScreenBounds *= -1
            offset = contentView.frame.origin.x
        }
        applyOffset(offset, view: contentView)
        
        drawTriangleForTabBarItemIndicator(contentView, tabbarItem: sourceView, backgroundColor: backgroundColor)
        
        return contentView
    }
    
    private func drawTriangleForTabBarItemIndicator(popupView: UIView, tabbarItem: UIView, backgroundColor: UIColor) {
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        let startPoint = (tabbarItem.center.x - arrowSize.width / 2) - popupView.frame.origin.x
        
        path.moveToPoint(CGPoint(x: startPoint, y: popupView.frame.size.height))
        path.addLineToPoint(CGPoint(x: startPoint + (arrowSize.width / 2), y: popupView.frame.size.height + arrowSize.height))
        path.addLineToPoint(CGPoint(x: startPoint + arrowSize.width, y: popupView.frame.size.height))
        
        path.closePath()
        
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = backgroundColor.CGColor
        popupView.layer.addSublayer(shapeLayer)
    }
    
    private func applyOffset(offset: CGFloat, view: UIView) {
        var frame = view.frame
        frame.origin.x -= (offset + popupMinMarginScreenBounds)
        view.frame = frame
    }
}

