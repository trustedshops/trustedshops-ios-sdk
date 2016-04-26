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

/**
 Displays the webView for the Trustbadge and passes it the order data to process.
 
 This method displays the webView that does the actual processing of the order data.
 To do that it calls the according setter methods in the loaded html's java script. A side effect of the current
 implementation is that it can only process one order at a time, even though it does so asynchronously.
 If you call this method a second time before the first call's completion block was executed,
 it fails (i.e. the second call's completion method is called with an error).
 
 @param order the `TRSOrder` object to be processed
 @param onCompletion A block that is called after the order was processed or after an error occured. A successful
 call passes nil as error. Its canceled parameter is TRUE if the user closed the webView without purchasing a guarantee, etc.
 */
- (void)processOrder:(nonnull TRSOrder *)order onCompletion:(nullable void (^)(BOOL canceled, NSError *_Nullable error))onCompletion;

@end
