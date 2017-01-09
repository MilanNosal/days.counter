//
//  KeyboardAdjustingViewController.swift
//  Olabot
//
//  Created by Milan Nosáľ on 13/12/2016.
//  Copyright © 2016 Olabot. All rights reserved.
//

import UIKit

class KeyboardAdjustingViewController: UIViewController {
    
    let keyboardAwareBottomLayoutGuide: UILayoutGuide = UILayoutGuide()
    private var topAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addLayoutGuide(keyboardAwareBottomLayoutGuide)
        topAnchorConstraint = view.bottomAnchor.constraint(equalTo: keyboardAwareBottomLayoutGuide.topAnchor, constant: 0)
        topAnchorConstraint.isActive = true
        keyboardAwareBottomLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAdjustingViewController.keyboardWillShowNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAdjustingViewController.keyboardWillHideNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateKeyboardAwareBottomLayoutGuide(with: notification, hiding: false)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateKeyboardAwareBottomLayoutGuide(with: notification, hiding: true)
    }
    
    func updateKeyboardAwareBottomLayoutGuide(with notification: NSNotification, hiding: Bool) {
        let userInfo = notification.userInfo
        
        let animationDuration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        let keyboardEndFrame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        
        let rawAnimationCurve = (userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uint32Value
        
        guard let animDuration = animationDuration,
            let keybrdEndFrame = keyboardEndFrame,
            let rawAnimCurve = rawAnimationCurve else {
                return
        }
        
        let convertedKeyboardEndFrame = view.convert(keybrdEndFrame, from: view.window)
        
        let rawAnimCurveAdjsted = UInt(rawAnimCurve << 16)
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimCurveAdjsted)
        
        topAnchorConstraint.constant = hiding ? 0 : convertedKeyboardEndFrame.size.height
        
        UIView.animate(withDuration: animDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
