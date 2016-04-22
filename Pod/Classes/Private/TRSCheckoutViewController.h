//
//  TRSCheckoutViewController.h
//  Pods
//
//  Created by Gero Herkenrath on 22/04/16.
//
//

/**
 This class displays a webview and loads the checkout UI right from the TS backend.
 The actual data processing is done in that webview (in java script).
 Besides sorting out the layout for the webview this controller calls a series of javascript in the webview's
 loaded content to hand over the necessary data gained from a TRSOrder object.
 
 To display the webview as a popover we use the MaryPopin category.
 */

#import <UIKit/UIKit.h>
@class TRSOrder;

@interface TRSCheckoutViewController : UIViewController

@property (nonatomic, readonly, assign) CGSize minPopoverSize;

- (void)processOrder:(nonnull TRSOrder *)order onCompletion:(nullable void (^)(NSError *_Nullable error))onCompletion;

@end
