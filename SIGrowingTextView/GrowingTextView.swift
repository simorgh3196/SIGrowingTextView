/////////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)
//
// Copyright (c) 2016 TomoyaHayakawa(@Sim_progra).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
/////////////////////////////////////////////////////////////////////////////////

import UIKit


// MARK: - GrowingTextViewDelegate -

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


// MARK: - GrowingTextView -

public class GrowingTextView: UITextView {
    
    public var maxNumberOfLines: Int = 0
    
    public var cornerRadius: CGFloat = 3 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    public var borderWidth: CGFloat = 0.25 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    public var borderColor: UIColor = UIColor(white: 0.7, alpha: 1) {
        didSet { layer.borderColor = borderColor.CGColor }
    }

    public var placeholder: String = "" {
        didSet { placeholderLabel.text = placeholder }
    }
    
    public var placeholderColor: UIColor = UIColor(white: 0.7, alpha: 1) {
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
    private var expectedHeight: CGFloat = 0
    public var minimumHeight: CGFloat {
        get {
            font = font ?? UIFont.systemFontOfSize(14)
            return font!.lineHeight + textContainerInset.top + textContainerInset.bottom
        }
        set { self.minimumHeight = newValue }
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
    
    
    // MARK: Lifecycle
    
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
        textContainerInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right:6)
        font = UIFont.systemFontOfSize(14)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.CGColor
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel.hidden = shouldHidePlaceholder()
        if !placeholderLabel.hidden {
            placeholderLabel.frame = placeholderRectThatFits(bounds)
            sendSubviewToBack(placeholderLabel)
        }
    }
    
    
    // MARK: Method
    
    private func updateSize() {
        
        var maxHeight = CGFloat.max
        
        if maxNumberOfLines > 0 {
            font = font ?? UIFont.systemFontOfSize(14)
            maxHeight
                = font!.lineHeight * CGFloat(maxNumberOfLines)
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
    }
    
    private func roundHeight() -> CGFloat {
        var newHeight: CGFloat = 0
        
        if let font = font {
            let boundingSize = CGSize(width: frame.size.width, height: CGFloat.max)
            let attr = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
            let size = attr.boundingRectWithSize(boundingSize, options: .UsesLineFragmentOrigin, context: nil)
            newHeight = size.height
        }
        
        return newHeight + textContainerInset.top + textContainerInset.bottom
    }
    
    private func shouldHidePlaceholder() -> Bool {
        return placeholder.isEmpty || !text.isEmpty
    }
    
    private func placeholderRectThatFits(rect: CGRect) -> CGRect {
        
        let size =  placeholderLabel.sizeThatFits(rect.size)
        var origin = UIEdgeInsetsInsetRect(rect, textContainerInset).origin
        let padding = textContainer.lineFragmentPadding
        origin.x += padding
        
        return CGRect(origin: origin, size: size)
    }
    
}


// MARK: - :UITextViewDelegate -

extension GrowingTextView: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return textViewDelegate?.textViewShouldBeginEditing?(self) ?? true
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return textViewDelegate?.textViewShouldEndEditing?(self) ?? true
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        textViewDelegate?.textViewDidBeginEditing?(self)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        textViewDelegate?.textViewDidEndEditing?(self)
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textViewDelegate?.textView?(self, shouldChangeTextInRange: range, replacementText: text) ?? true
    }

    public func textViewDidChange(textView: UITextView) {
        updateSize()
        placeholderLabel.hidden = shouldHidePlaceholder()
        textViewDelegate?.textViewDidChange?(self)
    }
    
    public func textViewDidChangeSelection(textView: UITextView) {
        textViewDelegate?.textViewDidChangeSelection?(self)
    }
    
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return textViewDelegate?.textView?(self, shouldInteractWithURL: URL, inRange: characterRange) ?? true
    }
    
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        return textViewDelegate?.textView?(self, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) ?? true
    }
}
