//
//  TRSTrustcardSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 22/03/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "TRSTrustcard.h"
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "TRSTrustbadge.h"
#import "NSURL+TRSURLExtensions.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "UIColor+TRSColors.h"

@interface TRSTrustcard (PrivateTests)

@property (weak, nonatomic) IBOutlet UIButton *certButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) TRSTrustbadge *displayedTrustbadge;

+ (UIFont *)openFontAwesomeWithSize:(CGFloat)size;
+ (void)dynamicallyLoadFontNamed:(NSString *)name;

@end

SpecBegin(TRSTrustcard)

describe(@"TRSTrustcard", ^{
	
	context(@"inited alone", ^{
		
		__block TRSTrustcard *testCard;
		__block TRSTrustbadge *testBadge;
		beforeAll(^{
			testCard = [[TRSTrustcard alloc] init];
			NSBundle *bundle = [NSBundle bundleForClass:[self class]];
			NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
			NSData *data = [NSData dataWithContentsOfFile:path];
			testBadge = [[TRSTrustbadge alloc] initWithData:data];
		});
		afterAll(^{
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
			
		});
		
		describe(@"-showInLightboxForTrustbadge:", ^{
			
			afterAll(^{
				[testCard buttonTapped:nil]; // need to close the card again and get into correct state
			});
			
			it(@"calls viewDidLoad", ^{
				id cardMock = OCMPartialMock(testCard);
				OCMExpect([cardMock viewDidLoad]);
				[testCard showInLightboxForTrustbadge:testBadge];
				OCMVerifyAll(cardMock);
			});
			
			// note: for now I don't test for viewWillAppear:, because it is called asynchronously and that's a pain
		});
		
		describe(@"-buttonTapped:", ^{
			
			context(@"while trustcard is showing", ^{
				
				beforeAll(^{
					[testCard showInLightboxForTrustbadge:testBadge];
					// the closing of the card is done in the tests
				});
				
				context(@"sender has tag of 1", ^{
					
					it(@"tries to open a URL in Safari", ^{
						NSURL *shopURL = [NSURL profileURLForShop:testBadge.shop];
						UIButton *testButton = [UIButton new];
						testButton.tag = 1;
						id appMock = OCMPartialMock([UIApplication sharedApplication]);
						OCMExpect([appMock openURL:shopURL]);
						[testCard buttonTapped:testButton];
						OCMVerifyAll(appMock);
					});
				});
				
				it(@"has a presenting view controller", ^{
					expect(testCard.presentingViewController).toNot.beNil;
				});
				
				it(@"calls dismissViewControllerAnimated:completion: on the presenting VC", ^{
					id vcMock = OCMPartialMock(testCard.presentingViewController); // prev test ensures it's not nil
					OCMExpect([[vcMock ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
					[testCard buttonTapped:nil];
					OCMVerifyAll(vcMock);
				});
			});
			
			context(@"while trustcard is not showing", ^{
				
				it(@"doesn't have a presenting view controller", ^{
					expect(testCard.presentingViewController).to.beNil;
				});
			});
			
		});
	});
	
	context(@"inited with its xib", ^{
		
		__block TRSTrustcard *testCard;
		__block TRSTrustbadge *testBadge;
		__block UIWindow *window;
		__block UIColor *testColor;
		beforeAll(^{
			testCard = [[TRSTrustcard alloc] initWithNibName:@"Trustcard" bundle:TRSTrustbadgeBundle()];
			NSBundle *bundle = [NSBundle bundleForClass:[self class]];
			NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
			NSData *data = [NSData dataWithContentsOfFile:path];
			testBadge = [[TRSTrustbadge alloc] initWithData:data];
			
			window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
			window.rootViewController = testCard;
			// note that with this we can't call showInLightboxForTrustbadge: since there's no root VC above us!
			
			testColor = [UIColor redColor];
			testCard.themeColor = testColor;
			[testCard view]; // this loads the view, thus sets IBOutlets and such
		});
		afterAll(^{
			testCard = nil;
			testBadge = nil;
			window = nil;
			[OHHTTPStubs removeAllStubs];
		});
		beforeEach(^{
			[window makeKeyAndVisible]; // this ultimately calls our viewWillAppear:
		});
		afterEach(^{
			window.hidden = YES;
		});
		
		it(@"prepares the  buttons in viewWillAppear:", ^{
			XCTAssertEqual(testColor, [testCard.okButton titleColorForState:UIControlStateNormal]);
			XCTAssertEqual(testColor, [testCard.certButton titleColorForState:UIControlStateNormal]);
			XCTAssertEqual(testColor, [testCard.okButton titleColorForState:UIControlStateNormal]);
		});
		
		it(@"calls loadRequest on its webView", ^{
			id mockView = OCMPartialMock(testCard.webView);
			OCMExpect([mockView loadRequest:[OCMArg any]]);
			[testCard viewWillAppear:NO];
			OCMVerifyAll(mockView);
		});
	});
});

SpecEnd
