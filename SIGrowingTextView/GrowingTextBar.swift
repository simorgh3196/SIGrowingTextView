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


// MARK: - GrowingTextBar -

@IBDesignable
public class GrowingTextBar: UIView {
    
    // MARK: IBInspectable Property
    // convenience propaties for IBInspectable
    
    // TextView maxNumberOfLines
    @IBInspectable public var maxNumberOfLines: Int {
        get { return textView.maxNumberOfLines }
        set { textView.maxNumberOfLines = newValue }
    }
    
    // TextView text
    @IBInspectable public var text: String {
        get { return textView.text }
        set {
            textView.text = newValue
            rightViewHidden = textView.text.isEmpty
        }
    }
    
    // TextView text color
    @IBInspectable public var textColor: UIColor? {
        get { return textView.textColor }
        set { textView.textColor = newValue }
    }
    
    // TextView corner radius
    @IBInspectable public var textViewCornerRadius: CGFloat {
        get { return textView.cornerRadius }
        set { textView.cornerRadius = newValue }
    }
    
    // TextView border width
    @IBInspectable public var textViewBorderWidth: CGFloat {
        get { return textView.borderWidth }
        set { textView.borderWidth = textViewBorderWidth }
    }
    
    // TextView border color
    @IBInspectable public var textViewBorderColor: UIColor {
        get { return textView.borderColor }
        set { textView.borderColor = newValue }
    }
    
    /// The text that appears as a placeholder when the text view is empty
    @IBInspectable public var placeholder: String {
        get { return textView.placeholder }
        set { textView.placeholder = newValue }
    }
    
    /// The color of the placeholder text
    @IBInspectable public var placeholderColor: UIColor {
        get { return textView.placeholderColor }
        set { textView.placeholderColor = newValue }
    }
    
    /// The font of the textView text and placeholder text
    @IBInspectable public var font: UIFont? {
        get { return textView.font }
        set { textView.font = newValue }
    }
    
    public var leftViewHidden: Bool = false {
        didSet {
            if leftViewHidden {
                leftViewWidthConstraint.constant = 0
            } else {
                leftViewWidthConstraint.constant = leftViewSize.width + sideViewMargin * 2
            }
        }
    }
    
    public var rightViewHidden: Bool = true {
        didSet {
            if rightViewHidden {
                rightViewWidthConstraint.constant = 0
            } else {
                rightViewWidthConstraint.constant = rightViewSize.width + sideViewMargin * 2
            }
        }
    }

    
    // MARK: Property
    
    public var textView: GrowingTextView!
    
    private var defaultHeight: CGFloat?
    private var sideViewMargin: CGFloat = 4
    
    private var leftView: UIView!
    private var rightView: UIView!
    
    private var leftViewSize: CGSize!
    private var rightViewSize: CGSize!
    private var leftViewWidthConstraint: NSLayoutConstraint!
    private var rightViewWidthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    
    // MARK: Lifecycle
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
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
        leftViewSize = CGSize(width: 40, height: 36)
        rightViewSize = CGSize(width: 40, height: 36)
        configureViews()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        for constraint in constraints {
            if constraint.firstAttribute == .Height && constraint.firstItem as? NSObject == self {
                heightConstraint = constraint
                defaultHeight = defaultHeight ?? constraint.constant
                break
            }
        }
    }
    
    
    // MARK: Public Method
    
    public func addSubviewToLeftView(view: UIView) {
        leftView.subviews.forEach({ $0.removeFromSuperview() })
        
        leftView.addSubview(view)
        view.sizeToFit()
        leftViewSize = view.frame.size
        
        view.translatesAutoresizingMaskIntoConstraints = false
        leftView.addConstraints([
            Constraint.new(view, .CenterX, to: leftView, .CenterX),
            Constraint.new(view, .CenterY, to: leftView, .CenterY)
            ])
        leftViewWidthConstraint.constant = view.frame.size.width + sideViewMargin*2
        
        updateLayout(duration: nil)
    }
    
    public func addSubviewToRightView(view: UIView, alwaysShow: Bool) {
        rightView.subviews.forEach({ $0.removeFromSuperview() })
        
        rightView.addSubview(view)
        view.sizeToFit()
        rightViewSize = view.frame.size
        
        view.translatesAutoresizingMaskIntoConstraints = false
        rightView.addConstraints([
            Constraint.new(view, .CenterX, to: rightView, .CenterX),
            Constraint.new(view, .CenterY, to: rightView, .CenterY)
            ])
        rightViewHidden =  alwaysShow || !textView.text.isEmpty
        
        updateLayout(duration: nil)
    }
    
    public func updateLayout(duration duration: NSTimeInterval?) {
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
    
    
    // MARK: Private Method
    
    private func configureViews() {
        textView = GrowingTextView()
        textView._textViewDelegate = self
        addSubview(textView)
        
        leftView = UIView()
        leftView.clipsToBounds = true
        addSubview(leftView)
        
        rightView = UIView()
        rightView.clipsToBounds = true
        addSubview(rightView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        leftViewWidthConstraint = Constraint.new(leftView, .Width, to: nil, .Width, constant: leftViewSize.width)
        rightViewWidthConstraint = Constraint.new(rightView, .Width, to: nil, .Width, constant: 0)
        addConstraints([leftViewWidthConstraint, rightViewWidthConstraint])
        
        addConstraints(Constraint.new(visualFormats: [
            "V:|-7-[textView]-7-|",
            "V:|-(>=4)-[leftView(36)]-4-|",
            "V:|-(>=4)-[rightView(36)]-4-|",
            "|-4-[leftView]-4-[textView]-4-[rightView]-4-|",
            ], views: ["textView" : textView, "leftView" : leftView, "rightView" : rightView]))
    }
}


// MARK: - :GrowingTextViewDelegate -

extension GrowingTextBar: _GrowingTextViewDelegate {
    
    public func textViewHeightChanged(textView: GrowingTextView, newHeight: CGFloat) {
        guard let defaultHeight = defaultHeight else { return }
        let padding = defaultHeight - textView.minimumHeight
        let height = padding + newHeight
        heightConstraint?.constant = height < defaultHeight ? defaultHeight : height
    }
    
    public func textViewDidChange(textView: GrowingTextView) {
        rightViewHidden = textView.text.isEmpty
        updateLayout(duration: 0.2)
    }
}
