//
//  GrowingTextBar.swift
//  SIGrowingTextView
//
//  Created by 早川智也 on 2016/05/21.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import UIKit


// MARK: - GrowingTextBar -

public class GrowingTextBar: UIView {
    
    
    // MARK: Property
    
    public var textView: GrowingTextView!
    
    private let defaultHeight: CGFloat = 44
    private var leftView: UIView!
    private var rightView: UIView!
    private var leftViewWidthConstraint: NSLayoutConstraint!
    private var rightViewWidthConstraint: NSLayoutConstraint!
    
    private var leftViewHidden: Bool = false {
        didSet { leftViewWidthConstraint.constant = rightViewHidden ? 0 : 40 }
    }
    
    private var rightViewHidden: Bool = true {
        didSet { rightViewWidthConstraint.constant = rightViewHidden ? 0 : 40 }
    }
    
    
    // MARK: Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        backgroundColor = UIColor(white: 0.7, alpha: 1)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        configureViews()
        updateAutolayout()
    }
    
    
    // MARK: Method
    
    public func addSubViewToLeftView(view: UIView) {
        
    }
    
    private func configureViews() {
        
        textView = GrowingTextView()
        textView.textViewDelegate = self
        textView.placeholder = "This is GrowingTextView"
        textView.maxNumberOfLines = 4
        addSubview(textView)
        
        leftView = UIView()
        leftView.backgroundColor = UIColor.blueColor()
        addSubview(leftView)
        
        rightView = UIView()
        rightView.backgroundColor = UIColor.blueColor()
        addSubview(rightView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateAutolayout() {
        
        leftViewWidthConstraint = Constraint.new(leftView, .Width, to: nil, .Width, constant: 40)
        rightViewWidthConstraint = Constraint.new(rightView, .Width, to: nil, .Width, constant: 0)
        
        addConstraints([leftViewWidthConstraint, rightViewWidthConstraint])
        addConstraints(
            Constraint.new(
                visualFormats: [
                    "V:|-7-[textView]-7-|",
                    "V:|-(>=4)-[leftView(36)]-4-|",
                    "V:|-(>=4)-[rightView(36)]-4-|",
                    "|-4-[leftView]-4-[textView]-4-[rightView]-4-|",
                ], views: ["textView" : textView, "leftView" : leftView, "rightView" : rightView])
        )
    }
    
    private func updateLayout(duration duration: NSTimeInterval?) {
        
        if let duration = duration {
            UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: { [weak self] in
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
                }, completion: nil)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}


// MARK: - :GrowingTextViewDelegate -

extension GrowingTextBar: GrowingTextViewDelegate {
    
    public func textViewHeightChanged(textView: GrowingTextView, newHeight: CGFloat) {
        
        let padding = defaultHeight - textView.minimumHeight
        let height = padding + newHeight
        
        for constraint in constraints {
            if constraint.firstAttribute == .Height && constraint.firstItem as? NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }
    }
    
    public func textViewDidChange(textView: GrowingTextView) {
        
        rightViewHidden = textView.text.isEmpty
        updateLayout(duration: 0.2)
    }
}
