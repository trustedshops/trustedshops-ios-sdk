#import "TRSCheckoutViewController.h"
#import "TRSOrder.h"
#import "TRSProduct.h"
#import "UIViewController+MaryPopin.h"
#import "TRSErrors.h"
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
		NSDate *todayPlusSevenDays = [NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0 * 7.0];
		testOrder.deliveryDate = todayPlusSevenDays;
		
		TRSProduct *testProduct1 = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.trustedshops.de"]
															  name:@"testproduct"
															   SKU:@"ThroughTheFireAndFlame"];
		TRSProduct *testProduct2 = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.trustedshops.de"]
															  name:@"producttest"
															   SKU:@"ResistanceIsFutile"];
		testOrder.tsCheckoutProductItems = @[testProduct1, testProduct2];
	});
	afterEach(^{
		testCheckout = nil;
		testOrder = nil;
		[testWindow setHidden:YES];
		[originalMainWindow makeKeyAndVisible];
	});
	
	// most important method!
	describe(@"-processOrder:onCompletion:", ^{
		it(@"saves the completionBlock for calling after closure", ^{
			void (^aBlock)(BOOL canceled, NSError *error) = ^(BOOL canceled, NSError *error) {
				// nothing in here
			};
			[testCheckout processOrder:testOrder onCompletion:aBlock];
			expect(testCheckout.completionBlock).to.equal(aBlock);
		});
		
		it(@"calls presentPopinController:animated:completion:", ^{
			id testRootMock = OCMPartialMock(testRoot);
			OCMExpect([testRootMock presentPopinController:[OCMArg any] animated:YES completion:[OCMArg any]]);
			[testCheckout processOrder:testOrder onCompletion:nil];
			OCMVerifyAll(testRootMock);
		});
		
		it(@"creates a WKWebView as its main view", ^{
			[testCheckout processOrder:testOrder onCompletion:nil];
			expect(testCheckout.view).to.beInstanceOf([WKWebView class]);
		});
		
		context(@"completion block's parameter for errors ", ^{
			it(@"is correct for missing root view controller", ^{
				id windowMock = OCMPartialMock(testWindow);
				OCMStub([windowMock rootViewController]).andReturn(nil);
				waitUntil(^(DoneCallback done) {
					[testCheckout processOrder:testOrder onCompletion:^(BOOL canceled, NSError * _Nullable error) {
						expect(error.domain).to.equal(TRSErrorDomain);
						expect(error.code).to.equal(TRSErrorDomainProcessOrderNeedsRootViewController);
						done();
					}];
				});
			});
			it(@"is correct for being called second time during processing", ^{
				[testCheckout processOrder:testOrder onCompletion:nil];
				waitUntil(^(DoneCallback done) {
					[testCheckout processOrder:testOrder onCompletion:^(BOOL canceled, NSError * _Nullable error) {
						expect(error.domain).to.equal(TRSErrorDomain);
						expect(error.code).to.equal(TRSErrorDomainProcessOrderLastOrderNotFinished);
						done();
					}];
				});
			});
			it(@"is correct for a corrupted order object", ^{
				// simply stub construct... to return NO instead of actually creating a corrupt order...
				id testCheckoutMock = OCMPartialMock(testCheckout);
				OCMStub([testCheckoutMock constructJavaScriptStringsForOrder:[OCMArg any]]).andReturn(NO);
				waitUntil(^(DoneCallback done) {
					[testCheckout processOrder:testOrder onCompletion:^(BOOL canceled, NSError * _Nullable error) {
						expect(error.domain).to.equal(TRSErrorDomain);
						expect(error.code).to.equal(TRSErrorDomainProcessOrderInvalidData);
						done();
					}];
				});
			});
		});
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
			expect(result).to.haveCountOf(9);
			expect([result allKeys]).to.beSupersetOf(@[@"email", @"ordernr", @"curr", @"amount", @"paymentType",
													   @"deliveryDate", @"addProduct", @"tsID", @"lastCall"]);
			NSArray *validStrings = @[
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutBuyerEmail('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderNr('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderCurrency('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderAmount('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderPaymentType('%s')",
				@"window.trustbadgeCheckoutManager.getOrderManager().setTsCheckoutOrderEstDeliveryDate('%s')",
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
			it(@"makes jsStrings have the correct count for our test order", ^{
				[testCheckout constructJavaScriptStringsForOrder:testOrder];
				expect(testCheckout.jsStrings).to.haveCountOf(10); // see set up of test order above (note: 2 products)
			});
		});
		context(@"with an invalid order", ^{
			it(@"returns NO", ^{
				[testOrder setValue:nil forKey:@"curr"]; //abuse KVC for creating a faulty order...
				expect([testCheckout constructJavaScriptStringsForOrder:testOrder]).to.beFalsy();
			});
		});
	});
	
	describe(@"-userContentController:didReceiveScriptMessage:", ^{
		// note: In the app this gets called due to a JS method in the webView. This is not tested here!
		it(@"dismisses the popin", ^{
			id testRootMock = OCMPartialMock(testRoot);
			OCMExpect([testRootMock dismissCurrentPopinControllerAnimated:YES completion:nil]);
			WKScriptMessage *testMessage = [[WKScriptMessage alloc] init];
			id testMessageMock = OCMPartialMock(testMessage);
			OCMStub([testMessageMock body]).andReturn(@"closed");
			// the tested method can only be called when the popin shows, so show it
			[testCheckout processOrder:testOrder onCompletion:nil];
			// note: the next lines get called BEFORE the webView has finished loading, so it's still blank, but that
			// is irrelevant for this test. In normal app usage, the tested method can obviously not get called
			// on an empty webView (since the webView's content ultimately triggers it)
			[testCheckout userContentController:nil didReceiveScriptMessage:testMessage];
			OCMVerifyAll(testRootMock);
		});
	});
	
	describe(@"-webView:didFinishNavigation:navigation", ^{
		// note: see previous test's comments: Since this is a delegation method, it's not called directly
		it(@"evluates the JS strings", ^{
			[testCheckout view]; // load the view/webView
			id webViewMock = OCMPartialMock(testCheckout.webView);
			OCMExpect([webViewMock evaluateJavaScript:[OCMArg any] completionHandler:[OCMArg any]]);
			[testCheckout processOrder:testOrder onCompletion:nil];
			[testCheckout webView:testCheckout.webView didFinishNavigation:nil];
			OCMVerifyAll(webViewMock);
		});
		// I don't test for JS errors (the if in the completion block), because that implies a faulty web content...
	});
	
	describe(@"webView:decidePolicyForNavigationAction:decisionHandler:", ^{
		
		it(@"calls the decision handler before JS was injected (first ever call)", ^{
			[testCheckout view];
			waitUntil(^(DoneCallback done) {
				// first call after webView is inited
				[testCheckout webView:testCheckout.webView decidePolicyForNavigationAction:nil
					  decisionHandler:^(WKNavigationActionPolicy policy) {
					expect(policy).to.equal(WKNavigationActionPolicyAllow); // first time we always allow
					done();
				}];
			});
		});
		
		it(@"calls decision handler & tries to open a URL after JS has been injected", ^{
			// note: I don't test the closing of the popin here, because that's a UI thing (& I didn't even show it)
			testCheckout.didInjectParameters = YES; // normally done by webViewDidFinish...
			id appMock = OCMPartialMock([UIApplication sharedApplication]);
			OCMExpect([appMock openURL:[OCMArg any]]);
			
			waitUntil(^(DoneCallback done) {
				[testCheckout webView:testCheckout.webView decidePolicyForNavigationAction:nil
					  decisionHandler:^(WKNavigationActionPolicy policy) {
						  expect(policy).to.equal(WKNavigationActionPolicyCancel);
						  OCMVerifyAll(appMock);
						  expect(testCheckout.tappedToCancel).to.beFalsy();
						  done();
				}];
			});
		});
	});
	
	describe(@"viewDidDisappear:", ^{
		it(@"calls the previously set completion block", ^{
			waitUntil(^(DoneCallback done) {
				[testCheckout processOrder:testOrder onCompletion:^(BOOL canceled, NSError * _Nullable error) {
					done();
				}];
				[testCheckout viewDidDisappear:YES];
			});
		});
		
		it(@"resets tappedToCancel to YES", ^{
			testCheckout.tappedToCancel = NO;
			[testCheckout processOrder:testOrder onCompletion:nil];
			[testCheckout viewDidDisappear:YES];
			expect(testCheckout.tappedToCancel).to.beTruthy();
		});
	});
	
});

SpecEnd
