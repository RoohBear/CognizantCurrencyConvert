//
//  UITableView+Setup.swift
//  CognizantCurrencyDemo
//
//  Created by Curtis Stilwell on 3/24/22.
//

import UIKit


extension UIView {
    
    func activateConstraints() {
        if let superview = superview {
            
            var constraintArray: [NSLayoutConstraint] = []
            
            switch self {
            case is UITableView :
                constraintArray = [ self.topAnchor.constraint(equalTo: superview.topAnchor),
                                    self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                                    self.leftAnchor.constraint(equalTo: superview.leftAnchor),
                                    self.rightAnchor.constraint(equalTo: superview.rightAnchor) ]
                break
                
            case is UIActivityIndicatorView :
                constraintArray = [self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                                   self.centerYAnchor.constraint(equalTo: superview.centerYAnchor)]
                break
                
            case is UILabel:
                constraintArray = [self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                                   self.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                                   self.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.7)]
                break
            default :
                break
            }
            if !constraintArray.isEmpty {
                NSLayoutConstraint.activate(constraintArray)
            }
        }
    }
    
}
