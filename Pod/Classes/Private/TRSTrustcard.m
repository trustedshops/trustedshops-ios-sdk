//
//  TRSTrustcard.m
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

static NSString * const TRSCertLocalFallback = @"trustcardfallback"; // not used atm
static NSString * const TRSCertHTMLName = @"trustinfos"; // not used atm

#import "TRSTrustcard.h"
#import "TRSTrustbadge.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "NSURL+TRSURLExtensions.h"
#import "UIColor+TRSColors.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSShop.h"
@import CoreText;
@import WebKit;
#import "UIViewController+MaryPopin.h"

static const CGSize minContentViewSize = {300.0, 380.0}; // This is a size used during initialization

@interface TRSTrustcard () <UIWebViewDelegate>

@property (weak, nonatomic) WKWebView *webView; // just for convenience, our view is actually the webView (so this can be weak)

@property (weak, nonatomic) TRSTrustbadge *displayedTrustbadge;
// this is weak to avoid a retain cycle (it's our owner), used for temporary stuff

@end

@implementation TRSTrustcard


- (void)loadView {
	WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
	WKUserContentController *ucController = [[WKUserContentController alloc] init]; // will probably later be used for scripts
	[ucController addScriptMessageHandler:self name:@"trs_ios_listener"];
	[ucController addUserScript:[[WKUserScript alloc] initWithSource:[self noZoomScriptString]
													   injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
													forMainFrameOnly:YES]];
	config.userContentController = ucController;
	self.view = [[WKWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, minContentViewSize.width, minContentViewSize.height)
								   configuration:config];
	self.webView = (WKWebView *) self.view;
	self.webView.navigationDelegate = self;
	self.webView.scrollView.scrollEnabled = NO;
}

- (void)showInLightboxForTrustbadge:(TRSTrustbadge *)trustbadge withPresentingViewController:(UIViewController *)presenter {
	
	if (!presenter) {
		// this is always there, but what happens if I have more than one? multi screen apps? test that somehow...
		UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
		
		self.displayedTrustbadge = trustbadge;
		presenter = mainWindow.rootViewController;
	}
	
	// ensure our view is loaded
	[self view];
	
	NSString *devFile = [TRSTrustbadgeBundle() pathForResource:@"trustcard_page" ofType:@"html"];
	NSURL *sampleURL = [NSURL fileURLWithPath:devFile];
	NSURLRequest *request = [NSURLRequest requestWithURL:sampleURL];
	[self.webView loadRequest:request];
	self.automaticallyAdjustsScrollViewInsets = NO; // fixes issue with nav bars & nav controllers as rootVC

	[presenter presentPopinController:self animated:YES completion:nil];
}

#pragma mark - WebView Delegation methods

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	if ([navigationAction.request.URL isFileURL]) { // this is the case only on first loading the card
		decisionHandler(WKNavigationActionPolicyAllow);
	} else { // this covers all links going out of the card (to the certificate and reviews and such)
		NSURL *buttonURL = navigationAction.request.URL;
		[[UIApplication sharedApplication] openURL:buttonURL];
		[self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:nil];
		// standard case: we opened the target in safari, so cancel it here.
		decisionHandler(WKNavigationActionPolicyCancel);
	}
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	NSString *jsCall = [self jsInjectionStringForID];
	[webView evaluateJavaScript:jsCall completionHandler:^(id _Nullable result, NSError * _Nullable error) {
		// if this ever happens, we're probably screwed...
		if (error && !(error.domain == WKErrorDomain && error.code == WKErrorJavaScriptResultTypeIsUnsupported)) {
			NSLog(@"JavaScript error: Could not inject the trustbadge; string: '%@', error: %@", jsCall, error);
		}
	}];
}

- (void)userContentController:(WKUserContentController *)userContentController
	  didReceiveScriptMessage:(WKScriptMessage *)message {
	
	if ([message.body isKindOfClass:[NSDictionary class]] && ([[message.body objectForKey:@"message"] isEqualToString:@"resize"])) {
		NSNumber *theWidth = [message.body objectForKey:@"width"];
		NSNumber *theHeight = [message.body objectForKey:@"height"];
		// TODO: add proper resizing code based on values here
		NSLog(@"cards width: %@ and height: %@", theWidth, theHeight);
		[self resizePopinToSize:CGSizeMake(theWidth.floatValue, theHeight.floatValue)];
	}
}

- (void)resizePopinToSize:(CGSize)newSize {
	// this method ensures the height is adapted after load (see also userContentController:didReceiveScriptMessage:)
	// it's basically the same as in TRSCheckoutViewController, but has a different "safety check" for height
	// and it tests whether an actual change is required first (to prevent a re-layouting cycle should the trustcard
	// react to a change of its view bounds with another change and so forth...)
	CGSize maxSize = [[UIScreen mainScreen] bounds].size;
	maxSize.height -= 30.0; // ensure parent view is always a bit smaller in height!
	newSize.width = MIN(maxSize.width, newSize.width); // don't go larger than the parent VC's view's size!
	newSize.height = MIN(maxSize.height, newSize.height);
	
	if (newSize.height != self.view.bounds.size.height || newSize.width != self.view.bounds.size.width) {
		self.view.contentMode = UIViewContentModeRedraw;
		[UIView animateWithDuration:0.1 animations:^{
			self.view.bounds = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
		}];
	}
}

#pragma mark - JavaScript helper methods

- (NSString *)jsInjectionStringForID {
	NSString *tsId = self.displayedTrustbadge.shop.tsId;
	if (!tsId || [tsId isEqualToString:@""]) {
		return nil;
	} else {
		return [NSString stringWithFormat:@"injectTrustbadge('%@', '%@')", tsId, self.debugMode ? TRSEndPointDebug : TRSEndPoint];
	}
}

- (NSString *)additionalJSCommands {
	return
	@"document.getElementById(\"MobileCoveringLayer_db8d3657bdbe440c985ae127463eaad4\").style.background = \"#ffdc0f\";"
	 "document.getElementById(\"tscard4_db8d3657bdbe440c985ae127463eaad4\").style.boxShadow = \"none\";"
	 "document.getElementById(\"Container_db8d3657bdbe440c985ae127463eaad4\").style.boxShadow = \"none\";"
	 "window.trustbadge.showCard()";
}

- (NSString *)noZoomScriptString {
	return
	@"var meta = document.createElement('meta');"
	 "meta.name = 'viewport';"
	 "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';"
	 "var head = document.getElementsByTagName('head')[0];"
	 "head.appendChild(meta);";
}

@end
