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
@import CoreText;

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
			
			it(@"doesn't yet have a presenting view controller", ^{
				expect(testCard.presentingViewController).to.beNil();
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
					expect(testCard.presentingViewController).toNot.beNil();
				});
				
				it(@"calls dismissViewControllerAnimated:completion: on the presenting VC", ^{
					id vcMock = OCMPartialMock(testCard.presentingViewController); // prev test ensures it's not nil
					OCMExpect([[vcMock ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
					[testCard buttonTapped:nil];
					OCMVerifyAll(vcMock);
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
	
	context(@"class methods", ^{
		
		describe(@"dynamicallyLoadFontNamed", ^{
			
			it(@"doesn't register a non-existant font", ^{
				// before: font not loaded
				UIFont *notthere = [UIFont fontWithName:@"gerosnonexistantfont" size:12.0];
				expect(notthere).to.beNil();
				[TRSTrustcard dynamicallyLoadFontNamed:@"gerosnonexistantfont"];
				// it's still not there!
				UIFont *stillnotthere = [UIFont fontWithName:@"gerosnonexistantfont" size:12.0];
				expect(stillnotthere).to.beNil();
			});
			
			it(@"properly handles garbage data gained from a file", ^{
				id dataClassMock = OCMClassMock([NSData class]);
				NSString *garbage = @"garbagedatastring";
				OCMStub([dataClassMock dataWithContentsOfURL:[OCMArg any]]).andReturn([garbage dataUsingEncoding:NSASCIIStringEncoding]);
				[TRSTrustcard dynamicallyLoadFontNamed:@"dontmatter"];
				
				[dataClassMock stopMocking];
			});
			
			it(@"registers fontawesome from the bundle", ^{
				// before: font not loaded
				UIFont *notthere = [UIFont fontWithName:@"fontawesome" size:12.0];
				expect(notthere).to.beNil();
				[TRSTrustcard dynamicallyLoadFontNamed:@"fontawesome"];
				// now it's there!
				UIFont *nowthere = [UIFont fontWithName:@"fontawesome" size:12.0];
				expect(nowthere).toNot.beNil();
				expect(nowthere.fontName).to.equal(@"fontawesome");
			});
		});
		
		describe(@"openFontAwesomeWithSite:", ^{
			
			it(@"returns a font object for a valid size", ^{
				UIFont *aFont = [TRSTrustcard openFontAwesomeWithSize:12.0];
				expect(aFont).toNot.beNil();
				expect(aFont).to.beKindOf([UIFont class]);
			});
			
			it(@"returns fontawesome for a valid size", ^{
				UIFont *aFont = [TRSTrustcard openFontAwesomeWithSize:12.0];
				expect([aFont fontName]).to.equal(@"fontawesome");
			});
			
			it(@"returns nil for an invalid font size", ^{
				UIFont *aFont = [TRSTrustcard openFontAwesomeWithSize:-4.0];
				expect(aFont).to.beNil();
			});
			
			it(@"lazy-loads the font if it's not already registered", ^{
				id classMock = OCMClassMock([TRSTrustcard class]);
				id uiFontMock = OCMClassMock([UIFont class]);
				__block BOOL stubbedOnce = NO; // ensure the stub is only called once!
				OCMStub([uiFontMock fontWithName:[OCMArg any] size:12.0])._andDo(^(NSInvocation *invocation) {
					[uiFontMock stopMocking];
					if (stubbedOnce) {
						[invocation setReturnValue:(__bridge void * _Nonnull)([UIFont fontWithName:@"fontawesome" size:12.0])];
					}
				});
				[TRSTrustcard openFontAwesomeWithSize:12.0];
				OCMVerify([classMock dynamicallyLoadFontNamed:[OCMArg any]]);
				[uiFontMock stopMocking];
				[classMock stopMocking];
			});
		});
	});
});

SpecEnd
