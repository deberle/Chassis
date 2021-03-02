//
//  UIView+Bodywork.swift
//  
//
//  Created by Daniel Eberle on 27.02.21.
//

import UIKit

extension UIView {

    public class func fromNib<T: UIView>() -> T {

        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
