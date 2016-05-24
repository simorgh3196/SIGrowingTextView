//
//  GrowingTextBar.swift
//  SIGrowingTextView
//
//  Created by 早川智也 on 2016/05/21.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import UIKit


public class GrowingTextBar: UIView {
    
    
    // MARK: Property
    
    public var textView: GrowingTextView!
    let defaultHeight = CGFloat(44)
    
    public var leftView: UIView? {
        willSet {
            if let view = leftView where newValue == nil {
                view.removeFromSuperview()
            }
        }
        didSet {
            if let view = leftView {
                addSubview(view)
            }
        }
    }
    
    public var rightView: UIView? {
        willSet {
            if let view = rightView where newValue == nil {
                view.removeFromSuperview()
            }
        }
        didSet {
            if let view = rightView {
                addSubview(view)
            }
        }
    }
    
    
    // MARK: Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        textView = GrowingTextView()
        textView.textViewDelegate = self
        textView.placeholder = "This is GrowingTextView"
        textView.maxNumberOfLines = 4
        addSubview(textView)
        setAutolayout()
    }
    
    
    // 
    
    private func setAutolayout() {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            Constraint.new(textView, .Top, to: self, .Top, constant: 7),
            Constraint.new(self, .Bottom, to: textView, .Bottom, constant: 7),
            Constraint.new(textView, .Left, to: self, .Left, constant: 16),
            Constraint.new(self, .Right, to: textView, .Right, constant: 16),
            ])
    }
    
    public func updateViews(animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.2) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

}


extension GrowingTextBar: GrowingTextViewDelegate {
    
    public func textViewHeightChanged(textView: GrowingTextView, newHeight: CGFloat) {
        
        let padding = defaultHeight - textView.minimumHeight
        let height = newHeight + 14//padding + newHeight
        
        for constraint in constraints {
            if constraint.firstAttribute == .Height && constraint.firstItem as? NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }
    }
    
    
    public func textViewDidChange(textView: GrowingTextView) {
        
        updateViews(true)
    }
    
}
