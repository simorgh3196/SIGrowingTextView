//
//  GrowingTextView.swift
//  SIGrowingTextView
//
//  Created by 早川智也 on 2016/05/21.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import UIKit


// MARK: - GrowingTextViewDelegate

@objc
public protocol GrowingTextViewDelegate: NSObjectProtocol {
    
    @available(iOS 2.0, *)
    optional func textViewShouldBeginEditing(textView: GrowingTextView) -> Bool
    @available(iOS 2.0, *)
    optional func textViewShouldEndEditing(textView: GrowingTextView) -> Bool
    
    @available(iOS 2.0, *)
    optional func textViewDidBeginEditing(textView: GrowingTextView)
    @available(iOS 2.0, *)
    optional func textViewDidEndEditing(textView: GrowingTextView)
    
    @available(iOS 2.0, *)
    optional func textView(textView: GrowingTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    @available(iOS 2.0, *)
    optional func textViewDidChange(textView: GrowingTextView)
    
    @available(iOS 2.0, *)
    optional func textViewDidChangeSelection(textView: GrowingTextView)
    
    @available(iOS 7.0, *)
    optional func textView(textView: GrowingTextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool
    @available(iOS 7.0, *)
    optional func textView(textView: GrowingTextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool
    
    optional func textViewHeightChanged(textView: GrowingTextView, newHeight: CGFloat)
    optional func textViewShouldReturn(textView: GrowingTextView) -> Bool
}


// MARK: - GrowingTextView

@IBDesignable
public class GrowingTextView: UITextView {
    
    // MARK: IBInspectable
    
    @IBInspectable public var maxNumberOfLines: Int = 0
    
    @IBInspectable public var cornerRadius: CGFloat = 3 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0.25 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable public var borderColor: UIColor = UIColor(white: 0.7, alpha: 1) {
        didSet { layer.borderColor = borderColor.CGColor }
    }

    @IBInspectable public var placeholder: String? {
        didSet { placeholderLabel.text = placeholder }
    }
    
    @IBInspectable public var placeholderColor: UIColor = UIColor(white: 0.7, alpha: 1) {
        didSet { placeholderLabel.textColor = placeholderColor }
    }
    
    
    // MARK: Property
    
    override public var font: UIFont? {
        didSet { placeholderLabel.font = font }
    }
    
    override public var contentSize: CGSize {
        didSet { updateSize() }
    }
    
    public weak var textViewDelegate: GrowingTextViewDelegate?
    public var expectedHeight: CGFloat = 0
    public var minimumHeight: CGFloat {
        font = font ?? UIFont.systemFontOfSize(14)
        return ceil(font!.lineHeight) + textContainerInset.top + textContainerInset.bottom
    }
    
    private lazy var placeholderLabel: UILabel = { [weak self] in
        let label = UILabel()
        label.clipsToBounds = false
        label.autoresizesSubviews = false
        label.numberOfLines = 1
        label.font = self?.font
        label.textColor = self?.placeholderColor
        label.backgroundColor = UIColor.clearColor()
        label.hidden = true
        self?.addSubview(label)
        
        return label
    }()
    
    
    // MARK: Initializer
    
    public convenience init() {
        self.init(frame: CGRectZero, textContainer: nil)
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        delegate = self
        clipsToBounds = true
        scrollEnabled = false
        textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right:6)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.CGColor
    }
    
    
    // MARK: Method
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel.hidden = shouldHidePlaceholder()
        if !placeholderLabel.hidden {
            placeholderLabel.frame = placeholderRectThatFits(bounds)
            sendSubviewToBack(placeholderLabel)
        }
    }
    
    /**
     Notify the delegate of size changes if necessary
     */
    private func updateSize() {
        
        var maxHeight = CGFloat.max
        
        if maxNumberOfLines > 0 {
            font = font ?? UIFont.systemFontOfSize(14)
            maxHeight
                = (ceil(font!.lineHeight) * CGFloat(maxNumberOfLines))
                + textContainerInset.top
                + textContainerInset.bottom
        }
        
        let roundedHeight = roundHeight()
        if roundedHeight >= maxHeight {
            expectedHeight = maxHeight
            scrollEnabled = true
        } else {
            expectedHeight = roundedHeight
            scrollEnabled = false
        }
        
        textViewDelegate?.textViewHeightChanged?(self, newHeight: expectedHeight)
        ensureCaretDisplaysCorrectly()
    }
    
    /**
     Calculates the correct height for the text currently in the textview as we cannot rely on contentsize to do the right thing
     */
    private func roundHeight() -> CGFloat {
        var newHeight: CGFloat = 0
        
        if let font = font {
            let boundingSize = CGSize(width: frame.size.width, height: CGFloat.max)
            let attr = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
            let size = attr.boundingRectWithSize(boundingSize, options: .UsesLineFragmentOrigin, context: nil)
            newHeight = ceil(size.height)
        }
        
        return newHeight + textContainerInset.top + textContainerInset.bottom
    }
    
    private func ensureCaretDisplaysCorrectly() {
        
        guard let range = selectedTextRange else { return }
        let rect = caretRectForPosition(range.end)
        UIView.performWithoutAnimation({ [weak self] in
            self?.scrollRectToVisible(rect, animated: false)
        })
    }
    
    private func shouldHidePlaceholder() -> Bool {
        return placeholder?.characters.count == 0 || text.characters.count > 0
    }

    /**
     Layout the placeholder label to fit in the rect specified
     
     - parameter rect: The constrained size in which to fit the label
     - returns: The placeholder label frame
     */
    private func placeholderRectThatFits(rect: CGRect) -> CGRect {
        
        let size =  placeholderLabel.sizeThatFits(rect.size)
        var origin = UIEdgeInsetsInsetRect(rect, textContainerInset).origin
        let padding = textContainer.lineFragmentPadding
        origin.x += padding
        
        return CGRect(origin: origin, size: size)
    }
    
}


// MARK: - :UITextViewDelegate

extension GrowingTextView: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print(#function, "text:", textView.text)
        return textViewDelegate?.textViewShouldBeginEditing?(self) ?? true
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        print(#function, "text:", textView.text)
        return textViewDelegate?.textViewShouldEndEditing?(self) ?? true
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        print(#function, "text:", textView.text)
        textViewDelegate?.textViewDidBeginEditing?(self)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        print(#function, "text:", textView.text)
        textViewDelegate?.textViewDidEndEditing?(self)
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        print(#function, "range:", range, "text:", text)
//        updateSize()
        var shouldChange = true
        if text == "\n" {
            if let change = textViewDelegate?.textViewShouldReturn?(self) {
                shouldChange = change
            }
        }
        if text.isEmpty {
            ensureCaretDisplaysCorrectly()
        }
        
        return shouldChange
    }

    public func textViewDidChange(textView: UITextView) {
        print(#function, "text:", textView.text)
        updateSize()
        placeholderLabel.hidden = shouldHidePlaceholder()
        textViewDelegate?.textViewDidChange?(self)
    }
    
    public func textViewDidChangeSelection(textView: UITextView) {
        print(#function, "text:", textView.text)
        textViewDelegate?.textViewDidChangeSelection?(self)
    }
    
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return textViewDelegate?.textView?(self, shouldInteractWithURL: URL, inRange: characterRange) ?? true
    }
    
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        print(#function, "text:", textView.text)
        return textViewDelegate?.textView?(self, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) ?? true
    }
}
