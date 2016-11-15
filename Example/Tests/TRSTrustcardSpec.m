//
//  TRSTrustcardSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 22/03/16.
//

#import "TRSTrustcard.h"
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "TRSTrustbadge.h"
#import "NSURL+TRSURLExtensions.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "UIColor+TRSColors.h"
#import "UIViewController+MaryPopin.h"
#import "TRSShop.h"
@import CoreText;
@import WebKit;

@interface TRSTrustcard (PrivateTests)

@property (weak, nonatomic) WKWebView *webView;
@property (weak, nonatomic) TRSTrustbadge *displayedTrustbadge;
@property (strong, nonatomic) NSTimer *resizingTimer;

// these are mostly delegate methods, but since we don't load a real page (no badge injection) we need to test them individually
- (void)resizePopinToSize:(CGSize)newSize;
- (void)checkContentSizeForFiringTimer:(NSTimer *)timer;
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
- (void)userContentController:(WKUserContentController *)userContentController
	  didReceiveScriptMessage:(WKScriptMessage *)message;
- (NSString *)jsInjectionStringForID;

@end

SpecBegin(TRSTrustcard)

describe(@"TRSTrustcard", ^{
	
//	context(@"inited alone", ^{
	
	__block TRSTrustcard *testCard;
	__block TRSTrustbadge *testBadge;
	beforeEach(^{
		testCard = [[TRSTrustcard alloc] init];
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
		NSData *data = [NSData dataWithContentsOfFile:path];
		testBadge = [[TRSTrustbadge alloc] initWithData:data];
	});
	afterEach(^{
		testCard = nil;
		testBadge = nil;
	});
	
	describe(@"-init", ^{
		
		it(@"is a subclass of UIViewController", ^{
			expect([testCard class]).to.beSubclassOf([UIViewController class]);
		});
		
		it(@"is an instance of TRSTrustcard", ^{
			expect(testCard).to.beKindOf([TRSTrustcard class]);
		});
		
		it(@"doesn't yet have a presenting view controller", ^{
			expect(testCard.presentingViewController).to.beNil();
		});
	});
	
	it(@"has a webView as view", ^{
		expect([testCard view]).to.beKindOf([WKWebView class]); // this calls load view
		expect([testCard webView]).to.beKindOf([WKWebView class]);
	});
	
	describe(@"showInLightboxForTrustbadge:withPresentingViewController:", ^{
		
		it(@"calls loadRequest on its webView", ^{
			[testCard view];
			id mockView = OCMPartialMock(testCard.webView);
			OCMExpect([(WKWebView *)mockView loadRequest:[OCMArg any]]);
			[testCard showInLightboxForTrustbadge:testBadge withPresentingViewController:nil];
			OCMVerifyAll(mockView);
			[testCard.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:nil];
		});
		
	});
	
	describe(@"checkContentSizeForFiringTimer:", ^{
		
		it(@"tries to evaluate javascript (successfully)", ^{
			[testCard view]; // make sure the webView is instantiated
			id mockView = OCMPartialMock(testCard.webView);
			id mockCard = OCMPartialMock(testCard);
			OCMExpect([mockCard resizePopinToSize:CGSizeMake(300.0, 380.0)]);
			// stub the webView evaluate method so it doesn't actually try to evaluate anything (without content)
			id fakeResult = @{@"width":@300.0, @"height":@380.0};
			OCMStub([(WKWebView *)mockView evaluateJavaScript:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:fakeResult, [NSNull null], nil])]);
			[mockCard checkContentSizeForFiringTimer:testCard.resizingTimer];
			OCMVerify([mockCard resizePopinToSize:CGSizeMake(300.0, 380.0)]);
		});
		
		it(@"handles a javascript error elegantly", ^{
			[testCard view]; // make sure the webView is instantiated
			id mockView = OCMPartialMock(testCard.webView);
			// stub the webView evaluate method so it doesn't actually try to evaluate anything (without content)
			NSError *fakeError = [NSError errorWithDomain:WKErrorDomain code:WKErrorJavaScriptResultTypeIsUnsupported userInfo:nil];
			id mockedError = OCMPartialMock(fakeError);
			OCMExpect([mockedError code]);
			OCMStub([(WKWebView *)mockView evaluateJavaScript:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:[NSNull null], mockedError, nil])]);
			[testCard checkContentSizeForFiringTimer:testCard.resizingTimer];
			OCMVerifyAll(mockedError);
		});

	});
	
	describe(@"webView:decidePolicyForNavigationAction:decisionHandler:", ^{
		
		it(@"starts a timer for navigating to a local file", ^{
			// prepare the first parameter...
			NSURL *sampleURL = [TRSTrustbadgeBundle() URLForResource:@"trustcard_page" withExtension:@"html"]; // not really used
			WKNavigationAction *fakeAction = [[WKNavigationAction alloc] init];
			id mockedFakeAction = OCMPartialMock(fakeAction);
			OCMStub([mockedFakeAction request]).andReturn([NSURLRequest requestWithURL:sampleURL]);
			
			// prepare the second parameter (the callback block, doesn't do anything for us here)
			void (^fakeBlock)(WKNavigationActionPolicy) = ^(WKNavigationActionPolicy policy) {
				
			};
			
			// prepare checking for the timer...
			id timerClassMock = OCMClassMock([NSTimer class]);
			NSTimer *myUnscheduledTimer = [NSTimer timerWithTimeInterval:0.2
																  target:testCard
																selector:@selector(checkContentSizeForFiringTimer:)
																userInfo:@"not really used timer"
																 repeats:NO];
			OCMStub([timerClassMock scheduledTimerWithTimeInterval:0.3
															target:testCard
														  selector:@selector(checkContentSizeForFiringTimer:)
														  userInfo:nil
														   repeats:YES]).andReturn(myUnscheduledTimer);
			[testCard webView:testCard.webView decidePolicyForNavigationAction:fakeAction decisionHandler:fakeBlock];
			expect(testCard.resizingTimer == myUnscheduledTimer).to.beTruthy();
		});
		
		it(@"tries to open URLs for non-local files", ^{
			// prepare the first parameter...
			NSURL *sampleURL = [NSURL URLWithString:@"https://www.google.de"];
			WKNavigationAction *fakeAction = [[WKNavigationAction alloc] init];
			id mockedFakeAction = OCMPartialMock(fakeAction);
			OCMStub([mockedFakeAction request]).andReturn([NSURLRequest requestWithURL:sampleURL]);
			
			// prepare the second parameter (the callback block, doesn't do anything for us here)
			void (^fakeBlock)(WKNavigationActionPolicy) = ^(WKNavigationActionPolicy policy) {
				
			};
			
			// mock the app object to catch url opening
			id appMock = OCMPartialMock([UIApplication sharedApplication]);
			OCMExpect([appMock openURL:sampleURL]);
			[testCard webView:testCard.webView decidePolicyForNavigationAction:fakeAction decisionHandler:fakeBlock];
			OCMVerifyAll(appMock);
		});
		
	});
	
	describe(@"webView:didFinishNavigation:", ^{
		
		it(@"tries to evaluate java script on the webView (and catches errors)", ^{
			[testCard view]; // make sure the webView is instantiated
			id mockView = OCMPartialMock(testCard.webView);
			// stub the webView evaluate method so it doesn't actually try to evaluate anything (without content)
			NSError *fakeError = [NSError errorWithDomain:WKErrorDomain code:WKErrorJavaScriptResultTypeIsUnsupported userInfo:nil];
			id mockedError = OCMPartialMock(fakeError);
			OCMExpect([mockedError code]);
			OCMStub([(WKWebView *)mockView evaluateJavaScript:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:[NSNull null], mockedError, nil])]);
			[testCard webView:testCard.webView didFinishNavigation:nil]; // the navigation object isn't really used...
			OCMVerifyAll(mockedError);
		});
		
	});
	
	describe(@"userContentController:didReceiveScriptMessage:", ^{
		
		it(@"tries to get width and height from the message's body", ^{
			WKScriptMessage *fakeMessage = [[WKScriptMessage alloc] init];
			// gotta mock it to deliver a prepared body...
			id mockedMessage = OCMPartialMock(fakeMessage);
			OCMStub([mockedMessage body]).andReturn((@{@"message":@"resize", @"width":@313.0, @"height":@417.0})); // use some stupid values
			[testCard userContentController:nil didReceiveScriptMessage:mockedMessage];
			expect(testCard.view.bounds.size.width).to.equal(313.0);
			expect(testCard.view.bounds.size.height).to.equal(417.0);
		});
		
	});
	
	describe(@"jsInjectionStringForID", ^{
		
		it(@"returns a valid javascript string if the badge has a tsid", ^{
			// the other case (no tsId) is basically covered above already
			testCard.displayedTrustbadge = testBadge;
			testCard.displayedTrustbadge.shop.tsId = @"X6A4AACCD2C75E430381B2E1C4CLASSIC";
			NSString *result = [testCard jsInjectionStringForID];
			expect([result hasPrefix:@"injectTrustbadge('X6A4AACCD2C75E430381B2E1C4CLASSIC', '"]).to.beTruthy();
			expect([result hasSuffix:@"')"]).to.beTruthy();
			// I leave out the endpoint... meh...
		});
		
	});
	
//	});
	
//	context(@"inited with its xib", ^{
//		
//		__block TRSTrustcard *testCard;
//		__block TRSTrustbadge *testBadge;
//		__block UIWindow *window;
//		__block UIColor *testColor;
//		beforeAll(^{
//			testCard = [[TRSTrustcard alloc] initWithNibName:@"Trustcard" bundle:TRSTrustbadgeBundle()];
//			NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//			NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
//			NSData *data = [NSData dataWithContentsOfFile:path];
//			testBadge = [[TRSTrustbadge alloc] initWithData:data];
//			
//			window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//			UIViewController *tempRootVC = [[UIViewController alloc] init];
//			tempRootVC.view.frame = window.bounds;
//			window.rootViewController = tempRootVC;
//			
//			testColor = [UIColor redColor];
//			testCard.themeColor = testColor;
//			[testCard view]; // this loads the view, thus sets IBOutlets and such
//		});
//		afterAll(^{
//			testCard = nil;
//			testBadge = nil;
//			window = nil;
//			[OHHTTPStubs removeAllStubs];
//		});
//		beforeEach(^{
//			[window makeKeyAndVisible];
//		});
//		afterEach(^{
//			window.hidden = YES;
//		});
//		
//		it(@"prepares the buttons in viewWillAppear:", ^{
//			[testCard showInLightboxForTrustbadge:testBadge withPresentingViewController:nil]; // this ultimately calls our viewWillAppear:
//			XCTAssertEqual(testColor, [testCard.okButton titleColorForState:UIControlStateNormal]);
//			XCTAssertEqual(testColor, [testCard.certButton titleColorForState:UIControlStateNormal]);
//			XCTAssertEqual(testColor, [testCard.okButton titleColorForState:UIControlStateNormal]);
//			[testCard buttonTapped:nil];
//		});
		
//		it(@"calls loadRequest on its webView", ^{
//			[testCard showInLightboxForTrustbadge:testBadge withPresentingViewController:nil]; // this ultimately calls our viewWillAppear:
//			id mockView = OCMPartialMock(testCard.webView);
//			OCMExpect([mockView loadRequest:[OCMArg any]]);
//			[testCard view];
//			OCMVerifyAll(mockView);
//			[testCard buttonTapped:nil];
//		});
				
//		describe(@"-buttonTapped:", ^{
//			
//			context(@"while trustcard is showing", ^{
//				
//				beforeAll(^{
//					[testCard showInLightboxForTrustbadge:testBadge withPresentingViewController:nil];
//					// the closing of the card is done in the tests
//				});
//				
//				context(@"sender has tag of 1", ^{
//					
//					it(@"tries to open a URL in Safari", ^{
//						NSURL *shopURL = [NSURL profileURLForShop:testBadge.shop];
//						UIButton *testButton = [UIButton new];
//						testButton.tag = 1;
//						id appMock = OCMPartialMock([UIApplication sharedApplication]);
//						OCMExpect([appMock openURL:shopURL]);
//						[testCard buttonTapped:testButton];
//						OCMVerifyAll(appMock);
//					});
//				});
//				
//				it(@"has a presentingPopin view controller", ^{
//					expect(testCard.presentingPopinViewController).toNot.beNil();
//				});
//				
//				it(@"calls dismissViewControllerAnimated:completion: on the presenting VC", ^{
//					id vcMock = OCMPartialMock(testCard.presentingPopinViewController); // prev test ensures it's not nil
//					OCMExpect([[vcMock ignoringNonObjectArgs] dismissCurrentPopinControllerAnimated:NO
//																						 completion:[OCMArg invokeBlock]]);
//					[testCard buttonTapped:nil];
//					OCMVerifyAll(vcMock);
//				});
//			});
//		});
//	});
	
//	context(@"class methods", ^{
//		
//		describe(@"dynamicallyLoadFontNamed", ^{
//			
//			it(@"doesn't register a non-existant font", ^{
//				// before: font not loaded
//				UIFont *notthere = [UIFont fontWithName:@"gerosnonexistantfont" size:12.0];
//				expect(notthere).to.beNil();
//				[TRSTrustcard dynamicallyLoadFontNamed:@"gerosnonexistantfont"];
//				// it's still not there!
//				UIFont *stillnotthere = [UIFont fontWithName:@"gerosnonexistantfont" size:12.0];
//				expect(stillnotthere).to.beNil();
//			});
//			
//			it(@"properly handles garbage data gained from a file", ^{
//				id dataClassMock = OCMClassMock([NSData class]);
//				NSString *garbage = @"garbagedatastring";
//				OCMStub([dataClassMock dataWithContentsOfURL:[OCMArg any]]).andReturn([garbage dataUsingEncoding:NSASCIIStringEncoding]);
//				[TRSTrustcard dynamicallyLoadFontNamed:@"dontmatter"];
//				
//				[dataClassMock stopMocking];
//			});
//			
//			it(@"registers fontawesome from the bundle", ^{
//				// before: font not loaded
//				UIFont *notthere = [UIFont fontWithName:@"fontawesome" size:12.0];
//				expect(notthere).to.beNil();
//				[TRSTrustcard dynamicallyLoadFontNamed:@"fontawesome"];
//				// now it's there!
//				UIFont *nowthere = [UIFont fontWithName:@"fontawesome" size:12.0];
//				expect(nowthere).toNot.beNil();
//				expect(nowthere.fontName).to.equal(@"fontawesome");
//			});
//		});
//		
//		describe(@"openFontAwesomeWithSite:", ^{
//			
//			it(@"returns a font object for a valid size", ^{
//				UIFont *aFont = [TRSTrustcard openFontAwesomeWithSize:12.0];
//				expect(aFont).toNot.beNil();
//				expect(aFont).to.beKindOf([UIFont class]);
//			});
//			
//			it(@"returns fontawesome for a valid size", ^{
//				UIFont *aFont = [TRSTrustcard openFontAwesomeWithSize:12.0];
//				expect([aFont fontName]).to.equal(@"fontawesome");
//			});
//			
//			it(@"returns nil for an invalid font size", ^{
//				UIFont *aFont = [TRSTrustcard openFontAwesomeWithSize:-4.0];
//				expect(aFont).to.beNil();
//			});
//			
//			it(@"lazy-loads the font if it's not already registered", ^{
//				id classMock = OCMClassMock([TRSTrustcard class]);
//				id uiFontMock = OCMClassMock([UIFont class]);
//				__block BOOL stubbedOnce = NO; // ensure the stub is only called once!
//				OCMStub([uiFontMock fontWithName:[OCMArg any] size:12.0])._andDo(^(NSInvocation *invocation) {
//					[uiFontMock stopMocking];
//					if (stubbedOnce) {
//						[invocation setReturnValue:(__bridge void * _Nonnull)([UIFont fontWithName:@"fontawesome" size:12.0])];
//					}
//				});
//				[TRSTrustcard openFontAwesomeWithSize:12.0];
//				OCMVerify([classMock dynamicallyLoadFontNamed:[OCMArg any]]);
//				[uiFontMock stopMocking];
//				[classMock stopMocking];
//			});
//		});
//	});
});

SpecEnd
