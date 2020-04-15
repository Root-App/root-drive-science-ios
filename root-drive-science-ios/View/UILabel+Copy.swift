//
//  UILabel+Copy.swift
//  root-drive-science-ios
//
//  Created by Austin Emmons on 4/6/20.
//  Copyright © 2020 Root. All rights reserved.
//

import UIKit

extension UILabel {
    public override var canBecomeFirstResponder: Bool { isUserInteractionEnabled }

    var isCopyEnabled: Bool {
        get {
            return recognizer != nil
        }
        set(newValue) {
            isUserInteractionEnabled = newValue
            if newValue {
                addGestureRecognizer(UILongPressGestureRecognizer(
                    target: self,
                    action: #selector(showMenu(sender:))
                ))
            }
        }
    }

    private var recognizer: UIGestureRecognizer? {
        gestureRecognizers?.find({ (recognizer) -> Bool in
            if let target = recognizer.forwardingTarget(for: #selector(showMenu(sender:))) as? UILabel {
                return target == self
            } else {
                return false
            }
        })
    }

    open override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    @objc func showMenu(sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy(_:))
    }
}
