//
//  File.swift
//  
//
//  Created by Daniel Eberle on 28.02.21.
//

import UIKit

extension UIStackView {

    @discardableResult
    public func removeArrangedSubviews() -> [UIView] {

        return arrangedSubviews.reduce([UIView]()) { $0 + [properlyRemove(subview:$1)] }
    }

    func properlyRemove(subview: UIView) -> UIView {

        self.removeArrangedSubview(subview)
        NSLayoutConstraint.deactivate(subview.constraints)
        subview.removeFromSuperview()
        return subview
    }
}
