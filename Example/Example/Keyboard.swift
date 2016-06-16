//
// # KeyboardObserver
// - GitHub: https://github.com/morizotter/KeyboardObserver
//

/////////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)
//
// Copyright (c) 2015 Morita Naoki
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
/////////////////////////////////////////////////////////////////////////////////

//
//  Keyboard.swift
//  Demo
//
//  Created by MORITANAOKI on 2015/12/14.
//  Copyright © 2015年 molabo. All rights reserved.
//

import UIKit

public enum KeyboardEventType {
    case WillShow
    case DidShow
    case WillHide
    case DidHide
    case WillChangeFrame
    case DidChangeFrame
    
    public var notificationName: String {
        switch self {
        case .WillShow:
            return UIKeyboardWillShowNotification
        case .DidShow:
            return UIKeyboardDidShowNotification
        case .WillHide:
            return UIKeyboardWillHideNotification
        case .DidHide:
            return UIKeyboardDidHideNotification
        case .WillChangeFrame:
            return UIKeyboardWillChangeFrameNotification
        case .DidChangeFrame:
            return UIKeyboardDidChangeFrameNotification
        }
    }
    
    init?(name: String) {
        switch name {
        case UIKeyboardWillShowNotification:
            self = .WillShow
        case UIKeyboardDidShowNotification:
            self = .DidShow
        case UIKeyboardWillHideNotification:
            self = .WillHide
        case UIKeyboardDidHideNotification:
            self = .DidHide
        case UIKeyboardWillChangeFrameNotification:
            self = .WillChangeFrame
        case UIKeyboardDidChangeFrameNotification:
            self = .DidChangeFrame
        default:
            return nil
        }
    }
    
    static func allEventNames() -> [String] {
        return [
            KeyboardEventType.WillShow,
            KeyboardEventType.DidShow,
            KeyboardEventType.WillHide,
            KeyboardEventType.DidHide,
            KeyboardEventType.WillChangeFrame,
            KeyboardEventType.DidChangeFrame
            ].map { $0.notificationName }
    }
}

public struct KeyboardEvent {
    public let type: KeyboardEventType
    public let keyboardFrameBegin: CGRect
    public let keyboardFrameEnd: CGRect
    public let curve: UIViewAnimationCurve
    public let duration: NSTimeInterval
    public var isLocal: Bool?
    
    public var options: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(curve.rawValue << 16))
    }
    
    init?(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return nil }
        guard let type = KeyboardEventType(name: notification.name) else { return nil }
        guard let begin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() else { return nil }
        guard let end = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else { return nil }
        guard
            let curveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.integerValue,
            let curve = UIViewAnimationCurve(rawValue: curveInt)
            else { return nil }
        guard
            let durationDouble = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else { return nil }
        
        self.type = type
        self.keyboardFrameBegin = begin
        self.keyboardFrameEnd = end
        self.curve = curve
        self.duration = NSTimeInterval(durationDouble)
        if #available(iOS 9, *) {
            guard let isLocalInt = (userInfo[UIKeyboardIsLocalUserInfoKey] as? NSNumber)?.integerValue else { return nil }
            self.isLocal = Bool(isLocalInt)
        }
    }
}

public enum KeyboardState {
    case Initial
    case Showing
    case Shown
    case Hiding
    case Hidden
    case Changing
}

public typealias KeyboardEventClosure = ((event: KeyboardEvent) -> Void)

public class KeyboardObserver {
    public var state = KeyboardState.Initial
    public var enabled = true
    private var eventClosures = [KeyboardEventClosure]()
    
    deinit {
        eventClosures.removeAll()
        KeyboardEventType.allEventNames().forEach {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: $0, object: nil)
        }
    }
    
    public init() {
        KeyboardEventType.allEventNames().forEach {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notified(_:)), name: $0, object: nil)
        }
    }
    
    public func observe(event: KeyboardEventClosure) {
        eventClosures.append(event)
    }
}

internal extension KeyboardObserver {
    @objc func notified(notification: NSNotification) {
        guard let event = KeyboardEvent(notification: notification) else { return }
        
        switch event.type {
        case .WillShow:
            state = .Showing
        case .DidShow:
            state = .Shown
        case .WillHide:
            state = .Hiding
        case .DidHide:
            state = .Hidden
        case .WillChangeFrame:
            state = .Changing
        case .DidChangeFrame:
            state = .Shown
        }
        
        if !enabled { return }
        eventClosures.forEach { $0(event: event) }
    }
}
