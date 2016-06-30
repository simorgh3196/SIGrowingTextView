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


internal final class Constraint: NSLayoutConstraint {
    static func new(
        item: AnyObject
        , _ attr: NSLayoutAttribute
        , to: AnyObject?
        , _ attrTo: NSLayoutAttribute
        , constant: CGFloat = 0.0
        , multiplier: CGFloat = 1.0
        , relate: NSLayoutRelation = .Equal
        , priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(
            item:       item,
            attribute:  attr,
            relatedBy:  relate,
            toItem:     to,
            attribute:  attrTo,
            multiplier: multiplier,
            constant:   constant
        )
        constraint.priority = priority
        return constraint
    }
    
    static func new(
        visualFormats formats: [String]
        , options opts: NSLayoutFormatOptions = NSLayoutFormatOptions(rawValue: 0)
        , metrics: [String : AnyObject]? = nil
        , views: [String : AnyObject]) -> [NSLayoutConstraint] {
        
        return formats.flatMap({
            NSLayoutConstraint.constraintsWithVisualFormat($0, options: opts, metrics: metrics, views: views)
        })
    }
}
