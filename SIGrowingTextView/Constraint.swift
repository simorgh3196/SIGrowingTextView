//
//  Constraint.swift
//  SIGrowingTextView
//
//  Created by 早川智也 on 2016/05/21.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import UIKit


internal struct Constraint {
    
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
