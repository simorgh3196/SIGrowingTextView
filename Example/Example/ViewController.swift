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
import SIGrowingTextView


class ViewController: UIViewController {

    @IBOutlet weak var growingTextBar: GrowingTextBar!
    @IBOutlet weak var growingViewBottomConstraint: NSLayoutConstraint!
    private let keyboard = KeyboardObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIButton(type: .ContactAdd)
        leftButton.addTarget(self, action: #selector(tappedButton(_:)), forControlEvents: .TouchUpInside)
        growingTextBar.addSubviewToLeftView(leftButton)
        
        let rightButton = UIButton(type: .System)
        rightButton.setTitle("Send", forState: .Normal)
        rightButton.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        rightButton.backgroundColor = UIColor.darkGrayColor()
        rightButton.layer.cornerRadius = 3
        rightButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        rightButton.addTarget(self, action: #selector(tappedButton(_:)), forControlEvents: .TouchUpInside)
        growingTextBar.addSubviewToRightView(rightButton, alwaysShow: true)
        
        keyboard.observe { [weak self] (event) -> Void in
            guard let s = self else { return }
            switch event.type {
            case .WillShow, .WillHide, .WillChangeFrame:
                let distance = UIScreen.mainScreen().bounds.height - event.keyboardFrameEnd.origin.y
                let bottom = distance >= s.bottomLayoutGuide.length ? distance : s.bottomLayoutGuide.length
                self?.growingViewBottomConstraint.constant = bottom
                
                UIView.animateWithDuration(event.duration, delay: 0.0, options: event.options, animations: {
                    self?.view.layoutIfNeeded()
                    self?.view.updateConstraints()
                    } , completion: nil)
            default:
                break
            }
        }
    }

    func tappedButton(sender: UIButton) {
        print(#function)
    }
    
}

