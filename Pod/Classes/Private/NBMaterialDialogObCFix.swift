//
//  NBMaterialDialogObCFix.swift
//  Pods
//
//  Created by Gero Herkenrath on 15.03.16.
//
//

import Foundation
import NBMaterialDialogIOS

@objc public class NBMaterialDialogObCFix : NBMaterialDialog {
	
	public var customBtnColor: UIColor?
	
	// for some reason the original function isn't added to the bridging header with the CGFloat as optional parameter.
	// this should fix that, basically it simply exposes the function to Objective-C code... derp
	public func showFromObjCDialog(windowView: UIView, title: String?, content: UIView, dialogHeight: CGFloat, okButtonTitle: String?, action: ((isOtherButton: Bool) -> Void)?, cancelButtonTitle: String?) -> NBMaterialDialog {
		let retVal =  showDialog(windowView, title: title, content: content, dialogHeight: dialogHeight, okButtonTitle: okButtonTitle, action: action, cancelButtonTitle: cancelButtonTitle)
		
		// dirty, dirty hack... find the buttons and set their title color
		if let topView = self.view.subviews.first {
			for candidateView in topView.subviews {
				if let btnView = candidateView as? UIButton {
					if self.customBtnColor != nil {
						btnView.setTitleColor(self.customBtnColor, forState: .Normal)
					}
				}
			}
		}
		
		return retVal;
	}

}