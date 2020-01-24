//
//  KeyPress.swift
//  Sessions Extension
//
//  Created by Alex Perathoner on 24/01/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Foundation
import AppKit
//import ScriptingBridge


class KeyPress {
	static let src = CGEventSource(stateID: .hidSystemState)
	static let commandControlMask = (CGEventFlags.maskCommand.rawValue | CGEventFlags.maskShift.rawValue)
	static let commandControlMaskFlags = CGEventFlags(rawValue: commandControlMask)

	static let loc: CGEventTapLocation = .cghidEventTap // kCGSessionEventTap also works
	
	static func simulateCmdShiftN() { //should open new private window
		
		//safari.activate() //just to be sure -> replace by the postToPid
		
		let ndown = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x2d), keyDown: true)
		let nup = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x2d), keyDown: false)

		ndown!.flags = commandControlMaskFlags
		nup!.flags = commandControlMaskFlags

		let pid = getPid("com.apple.Safari")!
		if let ndown = ndown {
			ndown.postToPid(pid)
		}
		if let nup = nup {
			nup.postToPid(pid)
		}
	}
	
	static func getPid(_ ofAppWithBundleID: String) -> pid_t? {
		for i in NSWorkspace.shared.runningApplications {
			if (i.bundleIdentifier == ofAppWithBundleID) {
				return i.processIdentifier
			}
		}
		return nil
	}
}
