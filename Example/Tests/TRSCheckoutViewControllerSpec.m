#import "TRSCheckoutViewController.h"
#import "TRSOrder.h"
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
@import WebKit;

@interface TRSCheckoutViewController (PrivateTest)

+ (NSDictionary *)baseJS;
- (BOOL)constructJavaScriptStringsForOrder:(TRSOrder *)order;
- (void)userContentController:(WKUserContentController *)userContentController
	  didReceiveScriptMessage:(WKScriptMessage *)message;
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@property (weak, nonatomic) WKWebView *webView;
@property (nonatomic, assign) BOOL didInjectParameters;
@property (nonatomic, strong) NSMutableArray *jsStrings;
@property (nonatomic, copy, nullable) void (^completionBlock)(BOOL canceled, NSError *_Nullable error);
@property (nonatomic, assign) BOOL tappedToCancel;

@end

SpecBegin(TRSCheckoutViewController)

describe(@"TRSCheckoutViewController", ^{
	// since this is a view controller I will set up my own window & root view controller for these tests
	__block UIWindow *testWindow;
	__block UIViewController *testRoot;
	__block id urlrequestMock;
	__block UIWindow *originalMainWindow;
	__block TRSCheckoutViewController *testCheckout;
	__block TRSOrder *testOrder;
	beforeAll(^{
		testWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		testRoot = [[UIViewController alloc] init];
		testRoot.view.frame = testWindow.frame;
		testWindow.rootViewController = testRoot;
		
		originalMainWindow = [[UIApplication sharedApplication] keyWindow];
		
		// ensure the webView doesn't actually load anything by stubbing the URLrequest generation
		urlrequestMock = OCMClassMock([NSURLRequest class]);
		NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"checkout_unit_test" ofType:@"html"];
		NSURLRequest *faked = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
		OCMStub([urlrequestMock requestWithURL:[OCMArg any]]).andReturn(faked);
	});
	afterAll(^{
		urlrequestMock = nil;
		testRoot = nil;
		testWindow = nil;
	});
	beforeEach(^{
		[testWindow makeKeyAndVisible];
		testCheckout = [[TRSCheckoutViewController alloc] initWithNibName:nil bundle:nil];
		testOrder = [[TRSOrder alloc] initWithTrustedShopsID:@"trustedShopsID"
													apiToken:@"apiToken"
													   email:@"email@example.com"
													 ordernr:@"orderNo"
													  amount:[NSNumber numberWithDouble:24.99]
														curr:@"EUR"
												 paymentType:@"PAYPAL"
												deliveryDate:nil];
	});
	afterEach(^{
		testCheckout = nil;
		testOrder = nil;
		[testWindow setHidden:YES];
		[originalMainWindow makeKeyAndVisible];
	});
	
	describe(@"-minPopoverSize", ^{
		it(@"returns a validCGSize", ^{
			expect([testCheckout minPopoverSize].width).to.beGreaterThan(0.0);
			expect([testCheckout minPopoverSize].height).to.beGreaterThan(0.0);
		});
	});
	
	describe(@"+baseJS", ^{
		it(@"returns a correct dictionary", ^{
			NSDictionary *result = [TRSCheckoutViewController baseJS];
			expect(result).to.haveCountOf(8);
			expect([result allKeys]).to.beSupersetOf(@[@"email", @"ordernr", @"curr", @"amount", @"paymentType",
													   @"addProduct", @"tsID", @"lastCall"]);
			NSArray *validStrings = @[
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutBuyerEmail('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderNr('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderCurrency('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderAmount('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderPaymentType('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().addProduct(%s)",
				@"injectTrustbadge('%s')",
				@"document.body.appendChild(window.trustbadgeCheckoutManager.getOrderManager().getTrustedShopsCheckoutElement())"];
			expect([result allValues]).to.beSupersetOf(validStrings);
		});
	});
	
	describe(@"-constructJavaScriptStringsForOrder:", ^{
		context(@"with a valid order", ^{
			it(@"returns YES", ^{
				expect([testCheckout constructJavaScriptStringsForOrder:testOrder]).to.beTruthy();
			});
			it(@"makes jsStrings have at least 7 elements", ^{
				[testCheckout constructJavaScriptStringsForOrder:testOrder];
				expect(testCheckout.jsStrings.count).to.beGreaterThanOrEqualTo(7);
			});
		});
	});
	
});

SpecEnd
