//
//  TRSCheckoutViewController.m
//  Pods
//
//  Created by Gero Herkenrath on 22/04/16.
//
//

#import "TRSCheckoutViewController.h"
#import "UIViewController+MaryPopin.h"
#import "TRSOrder.h"
#import "TRSProduct.h"
#import "TRSConsumer.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "TRSErrors.h"
@import WebKit;

static const CGSize minContentViewSize = {288.0, 339.0}; // for now: this is more or less defined by the displayed card...

@interface TRSCheckoutViewController () <WKNavigationDelegate, WKScriptMessageHandler>

@property (weak, nonatomic) WKWebView *webView; // this is just a convenience pointer..., view also holds it (strong)
@property (nonatomic, assign) BOOL didInjectParameters; // used to figure out whether I set the parameters in the webView

@property (nonatomic, strong) NSMutableArray *jsStrings;

@property (nonatomic, copy, nullable) void (^completionBlock)(BOOL canceled, NSError *_Nullable error);
@property (nonatomic, assign) BOOL tappedToCancel; // defaults to YES!

@end

@implementation TRSCheckoutViewController

// override getter to always return the defined constant above!
- (CGSize)minPopoverSize {
	return minContentViewSize;
}

- (void)loadView { // keep in mind this is only called once for each instance!
	self.tappedToCancel = YES; // we assume every close anywhere is a cancel unless explcitly said otherwise
	WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
	WKUserContentController *ucController = [[WKUserContentController alloc] init];
	[ucController addScriptMessageHandler:self name:@"trs_ios_listener"];
	config.userContentController = ucController;
	self.view = [[WKWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, minContentViewSize.width, minContentViewSize.height)
								   configuration:config];
	self.webView = (WKWebView *) self.view;
	self.didInjectParameters = NO;
	self.webView.navigationDelegate = self;
	self.webView.scrollView.scrollEnabled = NO;
}

- (void)processOrder:(nonnull TRSOrder *)order onCompletion:(nullable void (^)(BOOL canceled, NSError *_Nullable error))onCompletion {
	UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	if (!rootVC) {
		NSError *error = [NSError errorWithDomain:TRSErrorDomain
											 code:TRSErrorDomainProcessOrderNeedsRootViewController
										 userInfo:@{NSLocalizedDescriptionKey :
														@"need a root view controller to process order!"}];
		onCompletion(NO, error);
		return;
	}
	
	// ensure view is loaded (viewIfLoaded is iOS 9, so just use view)
	[self view];
	// if we still have strings/order data, we're called for the second time before finishing the first process, so fail
	if (self.jsStrings) {
		NSError *anotherError = [NSError errorWithDomain:TRSErrorDomain
													code:TRSErrorDomainProcessOrderLastOrderNotFinished
												userInfo:@{NSLocalizedDescriptionKey :
															   @"last order not processed yet"}];
		onCompletion(NO, anotherError);
		return;
	}
	
	// prepare the strings for the java script "handover" of parameters
	if (![self constructJavaScriptStringsForOrder:order]) {
		NSError *anotherError = [NSError errorWithDomain:TRSErrorDomain
													code:TRSErrorDomainProcessOrderInvalidData
												userInfo:@{NSLocalizedDescriptionKey :
															   @"order object invalid or corrupted"}];
		onCompletion(NO, anotherError);
		return;
	}
	
	// the development file:
	NSString *devFile = [TRSTrustbadgeBundle() pathForResource:@"checkout_page" ofType:@"html"];
	NSURL *sampleURL = [NSURL fileURLWithPath:devFile];
	NSURLRequest *request = [NSURLRequest requestWithURL:sampleURL];
	[self.webView loadRequest:request];
		
	self.completionBlock = onCompletion; // will be called later
	[rootVC presentPopinController:self animated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	self.completionBlock(self.tappedToCancel, nil);
	self.tappedToCancel = YES; // reset to default...
}

#pragma mark - WebView Delegation methods

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	
	if (!self.didInjectParameters) { // true if this is the first load
		decisionHandler(WKNavigationActionPolicyAllow);
	} else { // otherwise the user clicked somewhere in the webView
		// TODO: handle detecting the "close" button, if present: then deny the action
		
		// standard case: we will have to open the target in safari, so cancel it here.
		decisionHandler(WKNavigationActionPolicyCancel);
		NSURL *buttonURL = navigationAction.request.URL;
		[[UIApplication sharedApplication] openURL:buttonURL];
		
		// close the popin
		self.tappedToCancel = NO;
		[self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:nil];
	}
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	if (!self.didInjectParameters && self.jsStrings) {
		for (NSString *jsCall in self.jsStrings) {
			[webView evaluateJavaScript:jsCall completionHandler:^(id _Nullable result, NSError * _Nullable error) {
				// if this ever happens, we're probably screwed...
				if (error && !(error.domain == WKErrorDomain && error.code == WKErrorJavaScriptResultTypeIsUnsupported)) {
					NSLog(@"JavaScript error: Could not evaluate string: '%@', error: %@", jsCall, error);
				}
			}];
		}
		self.didInjectParameters = YES;
	}
}

#pragma mark - WebView User action (JS) handlers

- (void)userContentController:(WKUserContentController *)userContentController
	  didReceiveScriptMessage:(WKScriptMessage *)message {
	if ([message.body isEqualToString:@"closed"]) {
		[self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:nil];
	}
}

#pragma mark - JavaScript String helper

- (BOOL)constructJavaScriptStringsForOrder:(TRSOrder *)order {
	// validation note: actually, the order class already ensures needed values are present
	if (!order.consumer.email || !order.ordernr || !order.curr || !order.amount ||
		!order.paymentType || !order.tsID) {
		return NO;
	}
	
	self.jsStrings = [[NSMutableArray alloc] initWithCapacity:8];
	[self.jsStrings addObject:[[TRSCheckoutViewController baseJS][@"email"]
							   stringByReplacingOccurrencesOfString:@"%s" withString:order.consumer.email]];
	[self.jsStrings addObject:[[TRSCheckoutViewController baseJS][@"ordernr"]
							   stringByReplacingOccurrencesOfString:@"%s" withString:order.ordernr]];
	[self.jsStrings addObject:[[TRSCheckoutViewController baseJS][@"curr"]
							   stringByReplacingOccurrencesOfString:@"%s" withString:order.curr]];
	[self.jsStrings addObject:[[TRSCheckoutViewController baseJS][@"amount"]
							   stringByReplacingOccurrencesOfString:@"%s" withString:[order.amount stringValue]]];
	[self.jsStrings addObject:[[TRSCheckoutViewController baseJS][@"paymentType"]
							   stringByReplacingOccurrencesOfString:@"%s" withString:order.paymentType]];
	[self.jsStrings addObject:[[TRSCheckoutViewController baseJS][@"tsID"]
							   stringByReplacingOccurrencesOfString:@"%s" withString:order.tsID]];
	
	if (order.tsCheckoutProductItems) {
		for (TRSProduct *product in order.tsCheckoutProductItems) {
			[self.jsStrings addObject:[[TRSCheckoutViewController baseJS][@"addProduct"]
									   stringByReplacingOccurrencesOfString:@"%s" withString:[product jsStringDescription]]];
		}
	}
	
	// add the last airbend... er, call
	[self.jsStrings addObject:[TRSCheckoutViewController baseJS][@"lastCall"]];
	
	return YES;
}

+ (NSDictionary *)baseJS {
	return @{
			 @"email" : @"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutBuyerEmail('%s')",
			 @"ordernr" : @"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderNr('%s')",
			 @"curr" : @"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderCurrency('%s')",
			 @"amount" : @"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderAmount('%s')",
			 @"paymentType" : @"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderPaymentType('%s')",
			 @"addProduct" : @"window.trustbadgeCheckoutManager.getOrderManager().addProduct(%s)",
			 @"tsID" : @"injectTrustbadge('%s')",
			 @"lastCall" :
				 @"document.body.appendChild(window.trustbadgeCheckoutManager.getOrderManager().getTrustedShopsCheckoutElement())"
			 };
}

@end
