//
//  UISearchBar+Loading.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/12/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

extension UISearchBar {
    public var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textField
    }

    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }

    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width / 2, y: leftViewSize.height / 2)

                    // TODO: This is likely to break in the future.
                    newActivityIndicator.backgroundColor = UIColor(red: 224 / 255, green: 226 / 255, blue: 228 / 255, alpha: 1)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
