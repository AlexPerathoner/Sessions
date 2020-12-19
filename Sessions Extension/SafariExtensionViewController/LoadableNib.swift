//
//  LoadableNib.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 19/12/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Cocoa


protocol LoadableNib {
	var topView: NSView! { get }
}

extension LoadableNib where Self: NSView {

	///https://stackoverflow.com/a/51350799/6884062
	func loadViewFromNib() {
		loadViewFromCustomNib(fileName: String(describing: type(of: self)))
	}
	
	func loadViewFromCustomNib(fileName: String) {
		let bundle = Bundle(for: type(of: self))
		let nib = NSNib(nibNamed: .init(fileName), bundle: bundle)!
		_ = nib.instantiate(withOwner: self, topLevelObjects: nil)

		let contentConstraints = topView.constraints
		topView.subviews.forEach({ addSubview($0) })

		for constraint in contentConstraints {
			let firstItem = (constraint.firstItem as? NSView == topView) ? self : constraint.firstItem
			let secondItem = (constraint.secondItem as? NSView == topView) ? self : constraint.secondItem
			addConstraint(NSLayoutConstraint(item: firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
		}
	}
}
